param([switch]$InstallFresh)
$ErrorActionPreference = 'Stop'
$module = Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot = Get-QualificationRoot
$project = Join-Path $qualificationRoot 'remotion'
$nodeModules = Join-Path $project 'node_modules'
$cmd = (Get-Command cmd.exe -CommandType Application -ErrorAction Stop).Source
if (-not (Get-Command npm.cmd -CommandType Application -ErrorAction Stop)) { throw 'Official npm command is unavailable.' }
if (-not [IO.Directory]::Exists($nodeModules)) { throw 'The existing isolated Remotion dependency tree is missing.' }
if ($InstallFresh) { throw 'A fresh node_modules install would discard the already-qualified cache; CD-01 verifies npm ci from the lock in dry-run mode only.' }
$sandbox = New-QualificationSandbox -Purpose 'npm-lock-check'
$cache = Join-Path (Join-Path $env:TEMP 'nds-core-wo-001-runtime') 'npm-cache'
$environment = New-QualificationEnvironment -Sandbox $sandbox -Additional @{ npm_config_cache=$cache; npm_config_audit='false'; npm_config_fund='false'; npm_config_ignore_scripts='true' }
$ci = Invoke-QualificationProcess -FilePath $cmd -ArgumentList @('/d','/c','npm.cmd ci --dry-run --ignore-scripts --no-audit --no-fund --prefer-offline') -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 120
if ($ci.timed_out -or $ci.exit_code -ne 0) { throw "npm ci lock dry-run failed (exit $($ci.exit_code), timeout=$($ci.timed_out))." }
$ls = Invoke-QualificationProcess -FilePath $cmd -ArgumentList @('/d','/c','npm.cmd ls --depth=0') -WorkingDirectory $project -Sandbox $sandbox -Environment $environment -TimeoutSeconds 60
if ($ls.timed_out -or $ls.exit_code -ne 0) { throw 'npm ls failed for the installed isolated dependency tree.' }
$lock = Get-Content -Raw -LiteralPath (Join-Path $project 'package-lock.json') | ConvertFrom-Json -AsHashtable
$manifest = Get-Content -Raw -LiteralPath (Join-Path $project 'package.json') | ConvertFrom-Json -AsHashtable
$installedVersions = @()
foreach ($name in @('@remotion/cli','react','react-dom','remotion')) {
  $expected = [string]$manifest.dependencies[$name]
  $packageFile = Join-Path (Join-Path $nodeModules $name) 'package.json'
  if (-not [IO.File]::Exists($packageFile)) { throw "Installed package is missing: $name" }
  $installed = Get-Content -Raw -LiteralPath $packageFile | ConvertFrom-Json
  if ($installed.version -ne $expected) { throw "Installed version for $name does not match the pinned package.json version." }
  $installedVersions += "$name@$($installed.version)"
}
$remote = @($lock.packages.Values | Where-Object { $_.resolved })
$missingIntegrity = @($remote | Where-Object { -not $_.integrity })
$nonOfficial = @($remote | Where-Object { $_.resolved -notmatch '^https://registry\.npmjs\.org/' })
if ($missingIntegrity.Count -gt 0 -or $nonOfficial.Count -gt 0) { throw 'Lock contains a remote package without integrity or outside the official npm registry.' }
$evidence = [ordered]@{
  commands = @('npm.cmd ci --dry-run --ignore-scripts --no-audit --no-fund --prefer-offline','npm.cmd ls --depth=0')
  exit_codes = @($ci.exit_code,$ls.exit_code)
  npm_ci = 'PASS: exact package-lock reification plan verified without deleting or reinstalling node_modules'
  installed_tree = 'PASS'
  packages_with_resolved_and_integrity = $remote.Count
  packages_missing_integrity = $missingIntegrity.Count
  remote_sources_outside_official_npm_registry = $nonOfficial.Count
  package_lock_sha256 = (Get-FileHash -LiteralPath (Join-Path $project 'package-lock.json') -Algorithm SHA256).Hash
  lifecycle_scripts = 'disabled in verification/reproduction command'
  installed_versions = $installedVersions
  npm_ls_exit_zero = ($ls.exit_code -eq 0)
}
$logName = 'cd01-npm-lock-' + [Guid]::NewGuid().ToString('N')
$logRelative = Save-QualificationLog -Name $logName -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $logRelative
$evidence | ConvertTo-Json -Depth 8 -Compress
