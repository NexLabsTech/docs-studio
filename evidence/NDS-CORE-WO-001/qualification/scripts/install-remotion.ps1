param(
  [string]$RuntimeRoot = (Join-Path $env:TEMP 'nds-core-wo-001-runtime')
)

$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '..\remotion'
$cache = Join-Path $RuntimeRoot 'npm-cache'
New-Item -ItemType Directory -Force -Path $cache | Out-Null

Push-Location $project
try {
  npm install --cache $cache --no-audit --no-fund
  if ($LASTEXITCODE -ne 0) { throw "npm install failed: $LASTEXITCODE" }
  npm ls --depth=0
} finally {
  Pop-Location
}
