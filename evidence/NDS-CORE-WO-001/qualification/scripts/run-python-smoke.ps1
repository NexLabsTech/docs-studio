param(
  [Parameter(Mandatory=$true)][ValidateSet('tts','whisper','sqlite')][string]$Mode,
  [string]$InputFile,
  [string]$OutputFile,
  [string]$DatabaseFile,
  [string]$RunId = 'run-01',
  [string]$RuntimeRoot = (Join-Path $env:TEMP 'nds-core-wo-001-runtime'),
  [switch]$Offline
)

$ErrorActionPreference = 'Stop'
$python = Join-Path $RuntimeRoot 'python-venv\Scripts\python.exe'
$smoke = Join-Path $PSScriptRoot '..\python\smoke.py'
$runtimeTemp = Join-Path $RuntimeRoot 'temp'
$hfHome = Join-Path $RuntimeRoot 'hf-cache'
$transformersCache = Join-Path $RuntimeRoot 'transformers-cache'
$torchCache = Join-Path $RuntimeRoot 'torch-cache'
New-Item -ItemType Directory -Force -Path $runtimeTemp, $hfHome, $transformersCache, $torchCache | Out-Null

$arguments = @($smoke, $Mode)
if ($Mode -eq 'tts') {
  if (-not $OutputFile) { throw 'OutputFile is required for tts.' }
  $arguments += @('--output', $OutputFile)
} elseif ($Mode -eq 'whisper') {
  if (-not $InputFile) { throw 'InputFile is required for whisper.' }
  $arguments += @('--input', $InputFile)
} else {
  if (-not $DatabaseFile) { throw 'DatabaseFile is required for sqlite.' }
  $arguments += @('--db', $DatabaseFile)
}

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

$argumentLine = [string]::Join(' ', @($arguments | ForEach-Object { Quote-WindowsArgument ([string]$_) }))
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $python
$startInfo.Arguments = $argumentLine
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.EnvironmentVariables['TEMP'] = $runtimeTemp
$startInfo.EnvironmentVariables['TMP'] = $runtimeTemp
$startInfo.EnvironmentVariables['HF_HOME'] = $hfHome
$startInfo.EnvironmentVariables['HF_HUB_CACHE'] = Join-Path $hfHome 'hub'
$startInfo.EnvironmentVariables['TRANSFORMERS_CACHE'] = $transformersCache
$startInfo.EnvironmentVariables['TORCH_HOME'] = $torchCache
$startInfo.EnvironmentVariables['HF_HUB_DISABLE_TELEMETRY'] = '1'
$startInfo.EnvironmentVariables['HF_HUB_OFFLINE'] = if ($Offline) { '1' } else { '0' }
$startInfo.EnvironmentVariables['OMP_NUM_THREADS'] = '4'
$startInfo.EnvironmentVariables['MKL_NUM_THREADS'] = '4'
$startInfo.EnvironmentVariables['OPENBLAS_NUM_THREADS'] = '4'
$startInfo.EnvironmentVariables['CUDA_VISIBLE_DEVICES'] = ''
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
[void]$process.Start()
$stdoutTask = $process.StandardOutput.ReadToEndAsync()
$stderrTask = $process.StandardError.ReadToEndAsync()
$clock = [System.Diagnostics.Stopwatch]::StartNew()
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
  throw "Python $Mode smoke failed: $exitCode"
}

$stdoutLines = $stdoutTask.GetAwaiter().GetResult() -split '\r?\n'
$jsonLine = $stdoutLines | Where-Object { $_.TrimStart().StartsWith('{') } | Select-Object -Last 1
if (-not $jsonLine) { throw "Python $Mode smoke produced no JSON result." }
$result = $jsonLine | ConvertFrom-Json
$result | Add-Member -NotePropertyName process_peak_working_set_bytes -NotePropertyValue $peakWorkingSet
$result | Add-Member -NotePropertyName process_sample_count -NotePropertyValue $sampleCount
$result | Add-Member -NotePropertyName process_sample_interval_max_ms -NotePropertyValue ([math]::Round($maxSampleIntervalMilliseconds, 1))
$result | Add-Member -NotePropertyName memory_measurement -NotePropertyValue 'Windows process tree WorkingSetSize (WMI)'
$result | Add-Member -NotePropertyName exit_code -NotePropertyValue $exitCode

$logDirectory = Join-Path $PSScriptRoot '..\logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$safeName = ($RunId -replace '[^A-Za-z0-9-]', '-')
$logPath = Join-Path $logDirectory "$Mode-$safeName.json"
$jsonResult = $result | ConvertTo-Json -Depth 8 -Compress
Set-Content -LiteralPath $logPath -Value $jsonResult -Encoding utf8
Write-Output $jsonResult
