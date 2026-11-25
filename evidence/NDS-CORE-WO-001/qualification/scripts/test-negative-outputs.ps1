$ErrorActionPreference='Stop'
$module=Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot=Get-QualificationRoot
$sandbox=New-QualificationSandbox -Purpose 'negative'
$outside=Join-Path ([IO.Path]::GetDirectoryName($sandbox)) ('sentinel-' + [Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($outside)
$sentinel=Join-Path $outside 'sentinel.bin'
[IO.File]::WriteAllBytes($sentinel,[byte[]](19,73,11,221,8,44,61))
$sentinelHash=(Get-FileHash -LiteralPath $sentinel -Algorithm SHA256).Hash
$junction=Join-Path $sandbox 'junction'
New-Item -ItemType Junction -Path $junction -Target $outside | Out-Null
if(-not ((Get-Item -Force -LiteralPath $junction).Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'Test junction is not a Windows reparse point.'}
$python=Join-Path (Join-Path $env:TEMP 'nds-core-wo-001-runtime') 'python-venv\Scripts\python.exe'
$testPython=Join-Path $PSScriptRoot '..\python\test_sandbox.py'
$environment=New-QualificationEnvironment -Sandbox $sandbox -Additional @{NDS_TEST_EXTERNAL_SENTINEL=$sentinel}
$pythonTest=Invoke-QualificationProcess -FilePath $python -ArgumentList @($testPython) -WorkingDirectory (Join-Path $qualificationRoot 'python') -Sandbox $sandbox -Environment $environment -TimeoutSeconds 30
if($pythonTest.timed_out -or $pythonTest.exit_code -ne 0){throw 'Python path-negative tests failed.'}
$pythonResult=($pythonTest.stdout -split '\r?\n' | Where-Object {$_.TrimStart().StartsWith('{')} | Select-Object -Last 1) | ConvertFrom-Json
if(-not $pythonResult.passed){throw 'Python path assertions failed.'}

$pathChecks=[ordered]@{}
foreach($entry in @(
  @{Name='powershell_traversal_rejected';Path=('..\'+[IO.Path]::GetFileName($outside)+'\sentinel.bin')},
  @{Name='powershell_absolute_rejected';Path=$sentinel},
  @{Name='powershell_unc_rejected';Path='\\server\share\sentinel.bin'},
  @{Name='powershell_junction_reparse_rejected';Path='junction\new-output.bin'}
)){
  try{[void](Get-SandboxOutputPath -Sandbox $sandbox -RelativePath $entry.Path);$pathChecks[$entry.Name]=$false}catch{$pathChecks[$entry.Name]=$true}
}
$existing=Get-SandboxOutputPath -Sandbox $sandbox -RelativePath 'existing-powershell.bin'
[IO.File]::WriteAllBytes($existing,[byte[]](4,5,6,7,8))
$existingHash=(Get-FileHash -LiteralPath $existing -Algorithm SHA256).Hash
try{[void](Get-SandboxOutputPath -Sandbox $sandbox -RelativePath 'existing-powershell.bin');$pathChecks['powershell_existing_rejected']=$false}catch{$pathChecks['powershell_existing_rejected']=$true}
$pathChecks['powershell_existing_unchanged']=((Get-FileHash -LiteralPath $existing -Algorithm SHA256).Hash -eq $existingHash)
$pathChecks['external_sentinel_unchanged']=((Get-FileHash -LiteralPath $sentinel -Algorithm SHA256).Hash -eq $sentinelHash)
if(@($pathChecks.Values|Where-Object {$_ -ne $true}).Count -gt 0){throw 'PowerShell negative path tests failed.'}

$smoke=Join-Path $qualificationRoot 'python\smoke.py'
$oldDbAttempt=Invoke-QualificationProcess -FilePath $python -ArgumentList @($smoke,'sqlite','--db',$sentinel) -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 20
if($oldDbAttempt.timed_out -or $oldDbAttempt.exit_code -ne 2){throw 'Legacy arbitrary SQLite path argument was not rejected by argparse.'}
if((Get-FileHash -LiteralPath $sentinel -Algorithm SHA256).Hash -ne $sentinelHash){throw 'External sentinel changed after legacy SQLite argument rejection.'}

$evidence=[ordered]@{commands=@('test_sandbox.py','test-negative-outputs.ps1','negative legacy smoke.py sqlite --db argument');exit_codes=@($pythonTest.exit_code,$oldDbAttempt.exit_code);powershell_assertions=$pathChecks;python_assertions=$pythonResult.tests;legacy_sqlite_path_argument_rejected=$true;external_sentinel_before_sha256=$sentinelHash;external_sentinel_unchanged=$true;symlink_reparse_method='Windows directory junction';outputs_rejected='absolute, UNC, traversal, reparse and pre-existing destination';all_paths_refused_before_write=$true}
$log=Save-QualificationLog -Name ('cd01-negative-paths-'+[Guid]::NewGuid().ToString('N')) -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $log
$evidence | ConvertTo-Json -Depth 10 -Compress
[IO.Directory]::Delete($junction,$false)
[IO.File]::Delete($sentinel)
[IO.Directory]::Delete($outside,$false)