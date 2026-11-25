param(
  [string]$RuntimeRoot = (Join-Path $env:TEMP 'nds-core-wo-001-runtime')
)

$ErrorActionPreference = 'Stop'
$requirements = Join-Path $PSScriptRoot '..\python\requirements.txt'
$venv = Join-Path $RuntimeRoot 'python-venv'
$python = Join-Path $venv 'Scripts\python.exe'
$env:TEMP = Join-Path $RuntimeRoot 'temp'
$env:TMP = $env:TEMP

New-Item -ItemType Directory -Force -Path $RuntimeRoot, $env:TEMP | Out-Null
if (-not (Test-Path -LiteralPath $python)) {
  python -m venv $venv
  if ($LASTEXITCODE -ne 0) { throw "python -m venv failed: $LASTEXITCODE" }
}

# Install the CPU-only wheel from PyTorch's official index, without admin/global writes.
& $python -m pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu --no-deps 'torch==2.15.0+cpu'
if ($LASTEXITCODE -ne 0) { throw "CPU PyTorch install failed: $LASTEXITCODE" }

# Remaining official packages resolve from PyPI; the pinned CPU torch is already present.
& $python -m pip install --no-cache-dir -r $requirements
if ($LASTEXITCODE -ne 0) { throw "Python dependency install failed: $LASTEXITCODE" }

& $python -m pip check
if ($LASTEXITCODE -ne 0) { throw "pip check failed: $LASTEXITCODE" }
& $python -m pip freeze
