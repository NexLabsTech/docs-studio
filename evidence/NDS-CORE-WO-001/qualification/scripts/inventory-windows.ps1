$ErrorActionPreference = 'Stop'
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$gpus = @(Get-CimInstance Win32_VideoController | ForEach-Object {
  [ordered]@{ name = $_.Name; adapter_ram_bytes = if ($_.AdapterRAM) { [int64]$_.AdapterRAM } else { $null } }
})
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

function Get-ToolVersion([string]$Name, [string[]]$Arguments) {
  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $command) { return $null }
  $lines = @(& $command.Source @Arguments 2>&1)
  return [string]($lines | Select-Object -First 1)
}

$pythonCommand = Get-Command python -ErrorAction Stop
$pythonVersion = Get-ToolVersion 'python' @('--version')
$nodeVersion = Get-ToolVersion 'node' @('--version')
$npmVersion = Get-ToolVersion 'npm' @('--version')
$gitVersion = Get-ToolVersion 'git' @('--version')
$codexVersion = Get-ToolVersion 'codex' @('--version')
$sqliteVersion = [string](& $pythonCommand.Source -c 'import sqlite3; print(sqlite3.sqlite_version)')
$sqliteCliPresent = [bool](Get-Command sqlite3 -ErrorAction SilentlyContinue)
$ffmpeg = Get-Command ffmpeg -CommandType Application -ErrorAction Stop
$ffprobe = Get-Command ffprobe -CommandType Application -ErrorAction Stop
$ffmpegVersion = [string]((& $ffmpeg.Source -version 2>&1 | Select-Object -First 1))
$ffmpegConfig = [string]((& $ffmpeg.Source -version 2>&1 | Where-Object { $_ -match '^\s*configuration:' } | Select-Object -First 1))
$configPath = Join-Path $env:USERPROFILE '.codex\config.toml'
$codexModel = $null
$codexEffort = $null
if (Test-Path -LiteralPath $configPath) {
  foreach ($line in Get-Content -LiteralPath $configPath) {
    if ($line -match '^\s*model\s*=\s*"([^"]+)"') { $codexModel = $Matches[1] }
    if ($line -match '^\s*model_reasoning_effort\s*=\s*"([^"]+)"') { $codexEffort = $Matches[1] }
  }
}

$result = [ordered]@{
  collected_date = (Get-Date -Format 'yyyy-MM-dd')
  os = [ordered]@{ caption=$os.Caption; version=$os.Version; build=$os.BuildNumber; architecture=$os.OSArchitecture }
  cpu = [ordered]@{ name=$cpu.Name; cores=[int]$cpu.NumberOfCores; logical_processors=[int]$cpu.NumberOfLogicalProcessors; max_clock_mhz=[int]$cpu.MaxClockSpeed }
  physical_memory_gib = [math]::Round($os.TotalVisibleMemorySize * 1KB / 1GB, 2)
  gpus = $gpus
  c_drive = [ordered]@{ size_gib=[math]::Round($disk.Size / 1GB, 2); free_gib=[math]::Round($disk.FreeSpace / 1GB, 2) }
  tools = [ordered]@{
    python=$pythonVersion; node=$nodeVersion; npm=$npmVersion; git=$gitVersion; codex=$codexVersion
    sqlite_version=$sqliteVersion; sqlite_cli_present=$sqliteCliPresent
    ffmpeg=$ffmpegVersion; ffmpeg_sha256=(Get-FileHash -LiteralPath $ffmpeg.Source -Algorithm SHA256).Hash
    ffprobe_sha256=(Get-FileHash -LiteralPath $ffprobe.Source -Algorithm SHA256).Hash
    ffmpeg_gpl_enabled=($ffmpegConfig -match '--enable-gpl'); ffmpeg_libx264_enabled=($ffmpegConfig -match '--enable-libx264')
  }
  codex_local_config = [ordered]@{ model=$codexModel; reasoning_effort=$codexEffort }
  privacy = 'User name, home path, machine identifiers and credentials are excluded.'
}

$qualification = Split-Path -Parent $PSScriptRoot
$logDirectory = Join-Path $qualification 'logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$json = $result | ConvertTo-Json -Depth 6
Set-Content -LiteralPath (Join-Path $logDirectory 'windows-inventory.json') -Value $json -Encoding utf8
Write-Output ($result | ConvertTo-Json -Depth 6 -Compress)
