$ErrorActionPreference = 'Stop'
$module = Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot=Get-QualificationRoot
$project=Join-Path $qualificationRoot 'remotion'
$ffmpeg=(Get-Command ffmpeg -CommandType Application -ErrorAction Stop).Source
$ffprobe=(Get-Command ffprobe -CommandType Application -ErrorAction Stop).Source
$sandbox=New-QualificationSandbox -Purpose 'ffmpeg'
$output=Get-SandboxOutputPath -Sandbox $sandbox -RelativePath 'mix.mp4'
$environment=New-QualificationEnvironment -Sandbox $sandbox
$version=Invoke-QualificationProcess -FilePath $ffmpeg -ArgumentList @('-version') -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 20
if($version.timed_out -or $version.exit_code -ne 0){throw 'FFmpeg version query failed.'}
$arguments=@('-hide_banner','-loglevel','error','-n','-f','lavfi','-i','color=c=0x14223c:s=1280x720:r=30:d=5','-f','lavfi','-i','sine=frequency=440:sample_rate=48000:duration=5','-f','lavfi','-i','sine=frequency=880:sample_rate=48000:duration=5','-filter_complex','[1:a][2:a]amix=inputs=2:duration=shortest,volume=0.5[a]','-map','0:v:0','-map','[a]','-t','5','-c:v','libx264','-preset','ultrafast','-pix_fmt','yuv420p','-c:a','aac','-b:a','96k','-shortest',$output)
$encode=Invoke-QualificationProcess -FilePath $ffmpeg -ArgumentList $arguments -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 60
if($encode.timed_out){throw 'FFmpeg exceeded 60 seconds; its process tree was terminated.'}
if($encode.exit_code -ne 0){throw "FFmpeg encode failed with exit code $($encode.exit_code)."}
if(-not [IO.File]::Exists($output)){throw 'FFmpeg exited successfully without creating output.'}
$probeRun=Invoke-QualificationProcess -FilePath $ffprobe -ArgumentList @('-v','error','-show_entries','format=duration,size:stream=codec_type,codec_name,width,height,r_frame_rate,sample_rate,channels','-of','json',$output) -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 20
if($probeRun.timed_out -or $probeRun.exit_code -ne 0){throw 'ffprobe failed against the actual FFmpeg output.'}
$probe=$probeRun.stdout | ConvertFrom-Json
$video=@($probe.streams | Where-Object {$_.codec_type -eq 'video'}) | Select-Object -First 1
$audio=@($probe.streams | Where-Object {$_.codec_type -eq 'audio'}) | Select-Object -First 1
$duration=[double]$probe.format.duration
$file=Get-Item -LiteralPath $output
$checks=[ordered]@{duration_5s=([Math]::Abs($duration-5.0) -le 0.05);video_h264=($video.codec_name -eq 'h264');resolution_1280x720=([int]$video.width -eq 1280 -and [int]$video.height -eq 720);fps_30=($video.r_frame_rate -eq '30/1');audio_aac=($audio.codec_name -eq 'aac');audio_48khz=($audio.sample_rate -eq '48000');audio_mono=([int]$audio.channels -eq 1);size_matches=([int64]$probe.format.size -eq $file.Length)}
if(@($checks.Values | Where-Object {$_ -ne $true}).Count -gt 0){throw 'Actual ffprobe assertions failed for the FFmpeg output.'}
$evidence=[ordered]@{command='ffmpeg synthetic mix with -n; ffprobe actual output';ffmpeg_version=($version.stdout -split '\r?\n' | Select-Object -First 1);exit_code_ffmpeg=$encode.exit_code;exit_code_ffprobe=$probeRun.exit_code;timeout_seconds=60;elapsed_s=$encode.elapsed_s;process_tree_peak_working_set_bytes=$encode.process_tree_peak_working_set_bytes;process_samples=$encode.process_samples;memory_measurement='WMI WorkingSetSize da árvore do processo; amostragem 250 ms';actual_ffprobe=$probe;assertions=$checks;output_file='mix.mp4';output_bytes=$file.Length;output_sha256=(Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash}
$logName='cd01-ffmpeg-probe-' + [Guid]::NewGuid().ToString('N')
$logRelative=Save-QualificationLog -Name $logName -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $logRelative
$evidence | ConvertTo-Json -Depth 12 -Compress