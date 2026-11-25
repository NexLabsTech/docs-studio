param(
  [Parameter(Mandatory=$true)][ValidateSet('tts','whisper')][string]$Mode,
  [string]$InputFile,
  [int]$Iterations = 3,
  [switch]$Offline,
  [string]$RuntimeRoot = (Join-Path $env:TEMP 'nds-core-wo-001-runtime')
)

$ErrorActionPreference = 'Stop'
if ($Iterations -lt 1 -or $Iterations -gt 5) { throw 'Iterations must be between 1 and 5.' }
$runner = Join-Path $PSScriptRoot 'run-python-smoke.ps1'
$outputDirectory = Join-Path $RuntimeRoot 'outputs'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

for ($index = 1; $index -le $Iterations; $index++) {
  $runId = 'warm-{0:D2}' -f $index
  $offlineArgument = @()
  if ($Offline) { $offlineArgument = @('-Offline') }
  if ($Mode -eq 'tts') {
    $outputFile = Join-Path $outputDirectory "kokoro-$runId.wav"
    & $runner -Mode tts -RunId $runId -OutputFile $outputFile -RuntimeRoot $RuntimeRoot @offlineArgument
  } else {
    if (-not $InputFile) { throw 'InputFile is required for whisper.' }
    & $runner -Mode whisper -RunId $runId -InputFile $InputFile -RuntimeRoot $RuntimeRoot @offlineArgument
  }
}
