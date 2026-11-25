param(
  [int]$Iterations = 3,
  [string]$RuntimeRoot = (Join-Path $env:TEMP 'nds-core-wo-001-runtime')
)

$ErrorActionPreference = 'Stop'
if ($Iterations -lt 1 -or $Iterations -gt 5) { throw 'Iterations must be between 1 and 5.' }
$runner = Join-Path $PSScriptRoot 'render-remotion.ps1'
$outputDirectory = Join-Path $RuntimeRoot 'outputs'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

for ($index = 1; $index -le $Iterations; $index++) {
  $runId = 'warm-{0:D2}' -f $index
  $outputFile = Join-Path $outputDirectory "remotion-$runId.mp4"
  & $runner -OutputFile $outputFile -RuntimeRoot $RuntimeRoot
}
