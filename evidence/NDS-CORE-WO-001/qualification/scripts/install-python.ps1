param([switch]$InstallFresh)
$ErrorActionPreference = 'Stop'
$module = Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot = Get-QualificationRoot
$runtimeRoot = Join-Path $env:TEMP 'nds-core-wo-001-runtime'
$python = Join-Path $runtimeRoot 'python-venv\Scripts\python.exe'
$lock = Join-Path $PSScriptRoot '..\python\requirements-lock.txt'
$lockVerifier = Join-Path $PSScriptRoot '..\python\verify_lock.py'
if ($InstallFresh) { throw 'A new installation was not authorized for CD-01; the existing isolated environment is verified from the exact lock without reinstalling.' }
if (-not [IO.File]::Exists($python) -or -not [IO.File]::Exists($lock) -or -not [IO.File]::Exists($lockVerifier)) { throw 'The existing isolated Python runtime, lock or verifier is missing.' }
$sandbox = New-QualificationSandbox -Purpose 'pip-lock-check'
$environment = New-QualificationEnvironment -Sandbox $sandbox -Additional @{ PIP_DISABLE_PIP_VERSION_CHECK='1'; PIP_NO_INDEX='1'; HF_HUB_DISABLE_TELEMETRY='1'; HF_HUB_OFFLINE='1' }
$lockCheck = Invoke-QualificationProcess -FilePath $python -ArgumentList @('-m','pip','install','--no-index','--no-deps','--dry-run','--requirement',$lock) -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 120
if ($lockCheck.timed_out -or $lockCheck.exit_code -ne 0) { throw "Pinned Python lock check failed (exit $($lockCheck.exit_code), timeout=$($lockCheck.timed_out))." }
$check = Invoke-QualificationProcess -FilePath $python -ArgumentList @('-m','pip','check') -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 60
if ($check.timed_out -or $check.exit_code -ne 0) { throw 'pip check failed.' }
$freeze = Invoke-QualificationProcess -FilePath $python -ArgumentList @('-m','pip','freeze','--all') -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 60
if ($freeze.timed_out -or $freeze.exit_code -ne 0) { throw 'pip freeze failed.' }
$verification = Invoke-QualificationProcess -FilePath $python -ArgumentList @($lockVerifier) -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 60
if ($verification.timed_out -or $verification.exit_code -ne 0) { throw 'Installed distributions do not exactly match the pinned Python lock.' }
$verificationResult = $verification.stdout | ConvertFrom-Json
if (-not $verificationResult.passed) { throw 'Python lock package/version/hash comparison failed.' }
$evidence = [ordered]@{
  commands = @('python -m pip install --no-index --no-deps --dry-run --requirement requirements-lock.txt','python -m pip check','python -m pip freeze --all','python verify_lock.py')
  exit_codes = @($lockCheck.exit_code,$check.exit_code,$freeze.exit_code,$verification.exit_code)
  lock_check = 'PASS: complete installed distribution set, pinned versions and direct URL archive SHA-256 match the lock; no download or reinstall'
  pip_check = 'PASS'
  lock_comparison = $verificationResult
  freeze_lines = @($freeze.stdout -split '\r?\n' | Where-Object { $_ })
  lock_sha256 = (Get-FileHash -LiteralPath $lock -Algorithm SHA256).Hash
  environment = 'existing dedicated Python venv; source cache read-only and model calls offline'
}
$logName = 'cd01-python-lock-' + [Guid]::NewGuid().ToString('N')
$logRelative = Save-QualificationLog -Name $logName -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $logRelative
$evidence | ConvertTo-Json -Depth 8 -Compress
