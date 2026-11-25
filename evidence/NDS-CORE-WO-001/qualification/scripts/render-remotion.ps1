param(
  [Parameter(Mandatory=$true)][string]$OutputFile,
  [string]$RuntimeRoot = (Join-Path $env:TEMP 'nds-core-wo-001-runtime')
)

$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '..\remotion'
$cli = Join-Path $project 'node_modules\@remotion\cli\remotion-cli.js'
$env:TEMP = Join-Path $RuntimeRoot 'temp'
$env:TMP = $env:TEMP
$env:USERPROFILE = Join-Path $RuntimeRoot 'user-profile'
$env:LOCALAPPDATA = Join-Path $RuntimeRoot 'user-profile\AppData\Local'
$env:APPDATA = Join-Path $RuntimeRoot 'user-profile\AppData\Roaming'
$env:npm_config_cache = Join-Path $RuntimeRoot 'npm-cache'
New-Item -ItemType Directory -Force -Path $env:TEMP, $env:LOCALAPPDATA, $env:APPDATA | Out-Null
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
      if ($processIds.Contains([uint32]$candidate.ParentProcessId) -and $processIds.Add([uint32]$candidate.ProcessId)) {
        $changed = $true
      }
    }
  }
  $total = 0L
  foreach ($candidate in $processes) {
    if ($processIds.Contains([uint32]$candidate.ProcessId)) { $total += [int64]$candidate.WorkingSetSize }
  }
  return $total
}

if (-not (Test-Path -LiteralPath $cli)) { throw 'Pinned Remotion CLI is missing from the isolated project.' }
$node = (Get-Command node -ErrorAction Stop).Source
$arguments = @(
  $cli, 'render', 'src/index.jsx', 'nds-core-smoke', $OutputFile,
  '--codec=h264', '--concurrency=1', '--overwrite', '--log=error'
)
$argumentLine = [string]::Join(' ', @($arguments | ForEach-Object { Quote-WindowsArgument ([string]$_) }))
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $node
$startInfo.Arguments = $argumentLine
$startInfo.WorkingDirectory = $project
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
$clock = [System.Diagnostics.Stopwatch]::StartNew()
[void]$process.Start()
$stdoutTask = $process.StandardOutput.ReadToEndAsync()
$stderrTask = $process.StandardError.ReadToEndAsync()
$peakWorkingSet = 0L
$sampleCount = 0
$lastSampleMilliseconds = 0.0
$maxSampleIntervalMilliseconds = 0.0
while (-not $process.HasExited) {
  $now = $clock.Elapsed.TotalMilliseconds
  if ($sampleCount -gt 0) {
    $interval = $now - $lastSampleMilliseconds
    if ($interval -gt $maxSampleIntervalMilliseconds) { $maxSampleIntervalMilliseconds = $interval }
  }
  $lastSampleMilliseconds = $now
  $sample = Get-ProcessTreeWorkingSetBytes -RootProcessId ([uint32]$process.Id)
  if ($sample -gt $peakWorkingSet) { $peakWorkingSet = $sample }
  $sampleCount++
  Start-Sleep -Milliseconds 250
}
$process.WaitForExit()
$process.Refresh()
$exitCode = $process.ExitCode
if ($exitCode -ne 0) {
  [Console]::Error.WriteLine($stderrTask.GetAwaiter().GetResult())
  throw "Remotion render failed: $exitCode"
}
if (-not (Test-Path -LiteralPath $OutputFile)) { throw 'Remotion returned success but produced no output file.' }
$file = Get-Item -LiteralPath $OutputFile
$hash = (Get-FileHash -LiteralPath $OutputFile -Algorithm SHA256).Hash
$clock.Stop()
$result = [PSCustomObject]@{
  mode = 'remotion-cli-render'
  remotion_version = '4.0.547'
  node_version = (node --version)
  duration_s = 10
  width = 1920
  height = 1080
  fps = 30
  frames = 300
  codec = 'h264'
  concurrency = 1
  elapsed_s = [math]::Round($clock.Elapsed.TotalSeconds, 3)
  process_peak_working_set_bytes = $peakWorkingSet
  process_sample_count = $sampleCount
  process_sample_interval_max_ms = [math]::Round($maxSampleIntervalMilliseconds, 1)
  memory_measurement = 'Windows process tree WorkingSetSize (WMI)'
  output_bytes = $file.Length
  output_sha256 = $hash
  exit_code = $exitCode
}
$logDirectory = Join-Path $PSScriptRoot '..\logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$safeName = [IO.Path]::GetFileNameWithoutExtension($OutputFile) -replace '[^A-Za-z0-9-]', '-'
$logPath = Join-Path $logDirectory "remotion-$safeName.json"
$jsonResult = $result | ConvertTo-Json -Depth 5 -Compress
Set-Content -LiteralPath $logPath -Value $jsonResult -Encoding utf8
Write-Output $jsonResult
