param(
  [string]$OutputFile = (Join-Path $env:TEMP 'nds-core-wo-001-runtime\outputs\ffmpeg-mix-final.mp4')
)

$ErrorActionPreference = 'Stop'
$ffmpeg = (Get-Command ffmpeg -CommandType Application).Source
$ffprobe = (Get-Command ffprobe -CommandType Application).Source
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputFile) | Out-Null

function Quote-WindowsArgument([string]$Value) {
  if ($Value.Length -gt 0 -and $Value -notmatch '[\s"]') { return $Value }
  $builder = New-Object System.Text.StringBuilder
  [void]$builder.Append('"')
  $slashes = 0
  foreach ($character in $Value.ToCharArray()) {
    if ($character -eq '\') { $slashes++; continue }
    if ($character -eq '"') {
      [void]$builder.Append(('\' * (($slashes * 2) + 1)))
      [void]$builder.Append('"')
    } else {
      [void]$builder.Append(('\' * $slashes))
      [void]$builder.Append($character)
    }
    $slashes = 0
  }
  [void]$builder.Append(('\' * ($slashes * 2)))
  [void]$builder.Append('"')
  return $builder.ToString()
}

function Get-ProcessTreeWorkingSetBytes([uint32]$RootProcessId) {
  $processes = @(Get-CimInstance Win32_Process -Property ProcessId, ParentProcessId, WorkingSetSize)
  $processIds = New-Object 'System.Collections.Generic.HashSet[uint32]'
  [void]$processIds.Add($RootProcessId)
  $changed = $true
  while ($changed) {
    $changed = $false
    foreach ($candidate in $processes) {
      if ($processIds.Contains([uint32]$candidate.ParentProcessId) -and $processIds.Add([uint32]$candidate.ProcessId)) { $changed = $true }
    }
  }
  $total = 0L
  foreach ($candidate in $processes) { if ($processIds.Contains([uint32]$candidate.ProcessId)) { $total += [int64]$candidate.WorkingSetSize } }
  return $total
}

$versionLines = @(& $ffmpeg -version 2>&1)
if ($LASTEXITCODE -ne 0) { throw "ffmpeg version query failed: $LASTEXITCODE" }
$buildConfiguration = [string]($versionLines | Where-Object { $_ -match '^\s*configuration:' } | Select-Object -First 1)
$arguments = @(
  '-hide_banner', '-loglevel', 'error', '-y',
  '-f', 'lavfi', '-i', 'color=c=0x14223c:s=1280x720:r=30:d=5',
  '-f', 'lavfi', '-i', 'sine=frequency=440:sample_rate=48000:duration=5',
  '-f', 'lavfi', '-i', 'sine=frequency=880:sample_rate=48000:duration=5',
  '-filter_complex', '[1:a][2:a]amix=inputs=2:duration=shortest,volume=0.5[a]',
  '-map', '0:v:0', '-map', '[a]', '-t', '5',
  '-c:v', 'libx264', '-preset', 'ultrafast', '-pix_fmt', 'yuv420p',
  '-c:a', 'aac', '-b:a', '96k', '-shortest', $OutputFile
)
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $ffmpeg
$startInfo.Arguments = [string]::Join(' ', @($arguments | ForEach-Object { Quote-WindowsArgument ([string]$_) }))
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
[void]$process.Start()
$stdoutTask = $process.StandardOutput.ReadToEndAsync()
$stderrTask = $process.StandardError.ReadToEndAsync()
$clock = [System.Diagnostics.Stopwatch]::StartNew()
$peakWorkingSet = 0L
$sampleCount = 0
while (-not $process.HasExited) {
  $sample = Get-ProcessTreeWorkingSetBytes -RootProcessId ([uint32]$process.Id)
  if ($sample -gt $peakWorkingSet) { $peakWorkingSet = $sample }
  $sampleCount++
  Start-Sleep -Milliseconds 100
}
$process.WaitForExit()
$clock.Stop()
$exitCode = $process.ExitCode
if ($exitCode -ne 0) { throw "ffmpeg smoke failed: $exitCode $($stderrTask.GetAwaiter().GetResult())" }

$probeOutput = & $ffprobe -v error -show_entries 'format=duration,size:stream=codec_type,codec_name,width,height,sample_rate,channels' -of json $OutputFile
if ($LASTEXITCODE -ne 0) { throw "ffprobe smoke failed: $LASTEXITCODE" }
$probe = ($probeOutput -join "`n") | ConvertFrom-Json
$result = [ordered]@{
  mode = 'ffmpeg-mix-encode-ffprobe'
  ffmpeg_version = [string]$versionLines[0]
  ffmpeg_sha256 = (Get-FileHash -LiteralPath $ffmpeg -Algorithm SHA256).Hash
  ffprobe_sha256 = (Get-FileHash -LiteralPath $ffprobe -Algorithm SHA256).Hash
  build_configuration = $buildConfiguration
  elapsed_s = [math]::Round($clock.Elapsed.TotalSeconds, 3)
  process_tree_peak_working_set_bytes = $peakWorkingSet
  process_sample_count = $sampleCount
  memory_measurement = 'WMI process-tree WorkingSetSize sampled every 100 ms; one sample is a lower bound for this short encode'
  exit_code_ffmpeg = $exitCode
  exit_code_ffprobe = 0
  format = $probe.format
  streams = @($probe.streams | ForEach-Object { [ordered]@{ codec_type=$_.codec_type; codec_name=$_.codec_name; width=$_.width; height=$_.height; sample_rate=$_.sample_rate; channels=$_.channels } })
  output_bytes = (Get-Item -LiteralPath $OutputFile).Length
  output_sha256 = (Get-FileHash -LiteralPath $OutputFile -Algorithm SHA256).Hash
}
$logDirectory = Join-Path $PSScriptRoot '..\logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$jsonResult = $result | ConvertTo-Json -Depth 8 -Compress
Set-Content -LiteralPath (Join-Path $logDirectory 'ffmpeg-smoke-final.json') -Value $jsonResult -Encoding utf8
Write-Output $jsonResult
