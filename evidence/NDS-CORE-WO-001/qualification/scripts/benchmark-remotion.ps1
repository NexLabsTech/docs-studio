param([ValidateRange(1,5)][int]$Iterations=3)
$ErrorActionPreference='Stop'
$runner=Join-Path $PSScriptRoot 'render-remotion.ps1'
for($index=1;$index -le $Iterations;$index++){& $runner}