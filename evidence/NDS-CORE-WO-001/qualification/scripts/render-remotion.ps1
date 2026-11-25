$ErrorActionPreference = 'Stop'
$module = Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot = Get-QualificationRoot
$project = Join-Path $qualificationRoot 'remotion'
$cli = Join-Path $project 'node_modules\@remotion\cli\remotion-cli.js'
$node = (Get-Command node.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$ffprobe = (Get-Command ffprobe -CommandType Application -ErrorAction Stop).Source
if (-not [IO.File]::Exists($cli)) { throw 'Pinned Remotion CLI is missing from its isolated project.' }
$sandbox = New-QualificationSandbox -Purpose 'remotion'
$output = Get-SandboxOutputPath -Sandbox $sandbox -RelativePath 'render.mp4'
$environment = New-QualificationEnvironment -Sandbox $sandbox
$renderResult = Invoke-QualificationProcess -FilePath $node -ArgumentList @($cli,'render','src/index.jsx','nds-core-smoke',$output,'--codec=h264','--concurrency=1','--log=error') -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 300
if ($renderResult.timed_out) { throw 'Remotion exceeded the 300 second limit; its process tree was terminated.' }
if ($renderResult.exit_code -ne 0) { throw "Remotion render failed with exit code $($renderResult.exit_code)." }
if (-not [IO.File]::Exists($output)) { throw 'Remotion exited successfully without creating its output.' }
$probeResult = Invoke-QualificationProcess -FilePath $ffprobe -ArgumentList @('-v','error','-count_frames','-select_streams','v:0','-show_entries','format=duration,size:stream=codec_name,width,height,r_frame_rate,nb_frames,nb_read_frames','-of','json',$output) -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 30
if ($probeResult.timed_out -or $probeResult.exit_code -ne 0) { throw 'ffprobe failed against the actual Remotion output.' }
$probe = $probeResult.stdout | ConvertFrom-Json
$video = @($probe.streams | Where-Object { $_.codec_name }) | Select-Object -First 1
$duration = [double]$probe.format.duration
$frames = [int]$video.nb_read_frames
$file = Get-Item -LiteralPath $output
if ($video.codec_name -ne 'h264' -or [int]$video.width -ne 1920 -or [int]$video.height -ne 1080 -or $video.r_frame_rate -ne '30/1' -or $frames -ne 300 -or [Math]::Abs($duration - 10.0) -gt 0.02 -or [int64]$probe.format.size -ne $file.Length) {
  throw 'Real ffprobe assertions failed for codec, dimensions, frame rate, frame count, duration, or file size.'
}
$hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
$evidence = [ordered]@{
  command = 'node @remotion/cli/remotion-cli.js render; ffprobe -count_frames actual-output'
  exit_code_render = $renderResult.exit_code
  exit_code_ffprobe = $probeResult.exit_code
  timeout_seconds_render = 300
  timed_out = $false
  remotion_version = '4.0.547'
  output_file = 'render.mp4'
  output_bytes = $file.Length
  output_sha256 = $hash
  actual_ffprobe = $probe
  assertions = [ordered]@{ codec_h264=($video.codec_name -eq 'h264'); width_1920=([int]$video.width -eq 1920); height_1080=([int]$video.height -eq 1080); fps_30=($video.r_frame_rate -eq '30/1'); frames_300=($frames -eq 300); duration_10s=([Math]::Abs($duration - 10.0) -le 0.02); size_matches=([int64]$probe.format.size -eq $file.Length) }
  render_elapsed_s = $renderResult.elapsed_s
  render_process_tree_peak_working_set_bytes = $renderResult.process_tree_peak_working_set_bytes
  render_process_samples = $renderResult.process_samples
  memory_measurement = 'WMI WorkingSetSize soma da árvore do processo; amostragem a cada 250 ms'
}
$logName='cd01-remotion-probe-' + [Guid]::NewGuid().ToString('N')
$logRelative=Save-QualificationLog -Name $logName -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $logRelative
$evidence | ConvertTo-Json -Depth 12 -Compress
