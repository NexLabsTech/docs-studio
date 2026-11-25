$ErrorActionPreference='Stop'
$module=Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot=Get-QualificationRoot
$sandbox=New-QualificationSandbox -Purpose 'process-tests'
$environment=New-QualificationEnvironment -Sandbox $sandbox
$keys=@('TEMP','TMP','USERPROFILE','APPDATA','LOCALAPPDATA')
$parent=@{}
foreach($key in $keys){$parent[$key]=[Environment]::GetEnvironmentVariable($key,'Process')}
$privateName='NDS_CD01_PRIVATE_SENTINEL'
$privateBefore=[Environment]::GetEnvironmentVariable($privateName,'Process')
$pwsh=Join-Path $PSHOME 'pwsh.exe'
try {
  [Environment]::SetEnvironmentVariable($privateName,'must-not-cross-process-boundary','Process')
  $success=Invoke-QualificationProcess -FilePath $pwsh -ArgumentList @('-NoLogo','-NoProfile','-Command','[Console]::WriteLine($env:TEMP);[Console]::WriteLine($env:USERPROFILE);[Console]::WriteLine([string]::IsNullOrEmpty($env:NDS_CD01_PRIVATE_SENTINEL))') -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 20
} finally { [Environment]::SetEnvironmentVariable($privateName,$privateBefore,'Process') }
if($success.timed_out -or $success.exit_code -ne 0){throw 'Child success environment test failed.'}
$lines=@($success.stdout -split '\r?\n' | Where-Object {$_})
if($lines.Count -lt 3 -or $lines[0] -ne $environment.TEMP -or $lines[1] -ne $environment.USERPROFILE -or $lines[2] -ne 'True'){throw 'Child did not receive isolated TEMP/USERPROFILE or inherited a parent-only sentinel.'}
$unknownEnvironmentRejected=$false
try { [void](New-QualificationEnvironment -Sandbox $sandbox -Additional @{NDS_UNAPPROVED_ENV='1'}) } catch { $unknownEnvironmentRejected=$true }
if(-not $unknownEnvironmentRejected){throw 'Unapproved child environment variable was not rejected.'}
$failure=Invoke-QualificationProcess -FilePath $pwsh -ArgumentList @('-NoLogo','-NoProfile','-Command','exit 17') -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 20
if($failure.timed_out -or $failure.exit_code -ne 17){throw 'Child failure exit code was not preserved.'}
$childPidPath=Get-SandboxOutputPath -Sandbox $sandbox -RelativePath 'timeout-child-pid.txt'
$childScript='$p=Start-Process -FilePath "'+$pwsh+'" -ArgumentList @("-NoLogo","-NoProfile","-Command","Start-Sleep -Seconds 90") -PassThru;[IO.File]::WriteAllText("'+$childPidPath+'",[string]$p.Id);Start-Sleep -Seconds 90'
$encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childScript))
$timeout=Invoke-QualificationProcess -FilePath $pwsh -ArgumentList @('-NoLogo','-NoProfile','-EncodedCommand',$encoded) -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 20
if(-not $timeout.timed_out){throw 'Child timeout was not enforced.'}
if(-not [IO.File]::Exists($childPidPath)){throw 'Timeout child did not create its sandbox-only PID marker.'}
$childPid=[int](Get-Content -Raw -LiteralPath $childPidPath)
$processGone=$false
for($index=0;$index -lt 20;$index++){if(-not (Get-Process -Id $childPid -ErrorAction SilentlyContinue)){$processGone=$true;break};Start-Sleep -Milliseconds 150}
if(-not $processGone){throw 'Timeout cleanup left its own child process running.'}
$parentUnchanged=$true
foreach($key in $keys){if([Environment]::GetEnvironmentVariable($key,'Process') -ne $parent[$key]){$parentUnchanged=$false}}
if(-not $parentUnchanged){throw 'Parent environment changed during child success/failure/timeout.'}
$evidence=[ordered]@{commands=@('sanitized isolated pwsh child success','isolated pwsh exit 17','20 second timeout with child process','reject unapproved environment variables');success_exit_code=$success.exit_code;failure_exit_code=$failure.exit_code;timeout_seconds=20;timeout_enforced=$timeout.timed_out;child_process_terminated=$processGone;parent_temp_userprofile_appdata_unchanged=$parentUnchanged;parent_only_secret_sentinel_not_inherited=($lines[2] -eq 'True');unapproved_child_environment_rejected=$unknownEnvironmentRejected;process_tree_cleanup='Process.Kill(entireProcessTree) and bounded WaitForExit';all_child_environment_isolated=$true}
$log=Save-QualificationLog -Name ('cd01-process-tests-'+[Guid]::NewGuid().ToString('N')) -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $log
$evidence | ConvertTo-Json -Depth 8 -Compress
