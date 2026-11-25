Set-StrictMode -Version Latest

$script:QualificationRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:SandboxParent = Join-Path $script:QualificationRoot '.runtime\runs'

function Get-QualificationRoot { return $script:QualificationRoot }

function Assert-NoReparsePoints([string]$Path) {
  $full = [IO.Path]::GetFullPath($Path)
  $volume = [IO.Path]::GetPathRoot($full)
  $relative = $full.Substring($volume.Length)
  $current = $volume
  foreach ($part in ($relative -split '[\\/]')) {
    if (-not $part) { continue }
    $current = Join-Path $current $part
    $item = Get-Item -Force -LiteralPath $current -ErrorAction SilentlyContinue
    if ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
      throw "Reparse point refused in qualification path."
    }
  }
}

function Assert-QualificationSandbox([string]$Sandbox) {
  if (-not $Sandbox) { throw 'Sandbox is required.' }
  $full = [IO.Path]::GetFullPath($Sandbox)
  $parent = [IO.Path]::GetFullPath([IO.Path]::GetDirectoryName($full))
  $expected = [IO.Path]::GetFullPath($script:SandboxParent)
  if (-not [string]::Equals($parent, $expected, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Sandbox must be a direct child of the qualification run directory.'
  }
  if ([IO.Path]::GetFileName($full) -notmatch '^run-[a-z0-9-]{2,24}-[a-f0-9]{32}$') {
    throw 'Sandbox name is not a fresh qualification run identifier.'
  }
  if (-not [IO.Directory]::Exists($full)) { throw 'Sandbox does not exist.' }
  Assert-NoReparsePoints $full
}

function New-QualificationSandbox([string]$Purpose) {
  if ($Purpose -notmatch '^[a-z][a-z0-9-]{1,20}$') { throw 'Invalid sandbox purpose.' }
  Assert-NoReparsePoints $script:QualificationRoot
  $runtime = Join-Path $script:QualificationRoot '.runtime'
  if (Test-Path -LiteralPath $runtime) { Assert-NoReparsePoints $runtime }
  [void][IO.Directory]::CreateDirectory($runtime)
  $runs = Join-Path $runtime 'runs'
  if (Test-Path -LiteralPath $runs) { Assert-NoReparsePoints $runs }
  [void][IO.Directory]::CreateDirectory($runs)
  Assert-NoReparsePoints $runs
  $candidate = Join-Path $runs ('run-' + $Purpose + '-' + [Guid]::NewGuid().ToString('N'))
  if (Test-Path -LiteralPath $candidate) { throw 'Fresh run directory already exists.' }
  [void][IO.Directory]::CreateDirectory($candidate)
  Assert-QualificationSandbox $candidate
  return $candidate
}

function Get-SandboxOutputPath([string]$Sandbox, [string]$RelativePath) {
  Assert-QualificationSandbox $Sandbox
  if (-not $RelativePath -or [IO.Path]::IsPathRooted($RelativePath) -or $RelativePath.Contains(':') -or $RelativePath.StartsWith('\\') -or $RelativePath.StartsWith('//')) {
    throw 'Only a relative output path is accepted.'
  }
  $parts = $RelativePath -split '[\\/]'
  if ($parts.Count -eq 0 -or @($parts | Where-Object { -not $_ -or $_ -eq '.' -or $_ -eq '..' }).Count -gt 0) {
    throw 'Traversal or empty path component refused.'
  }
  $full = [IO.Path]::GetFullPath((Join-Path $Sandbox $RelativePath))
  $prefix = [IO.Path]::GetFullPath($Sandbox).TrimEnd('\') + '\'
  if (-not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Output path escapes its qualification sandbox.'
  }
  Assert-NoReparsePoints $full
  $item = Get-Item -Force -LiteralPath $full -ErrorAction SilentlyContinue
  if ($null -ne $item) { throw 'Existing output destination refused.' }
  return $full
}

function New-QualificationEnvironment([string]$Sandbox, [hashtable]$Additional = @{}) {
  Assert-QualificationSandbox $Sandbox
  $profile = Join-Path $Sandbox 'profile'
  $local = Join-Path $profile 'AppData\Local'
  $roaming = Join-Path $profile 'AppData\Roaming'
  $temp = Join-Path $Sandbox 'temp'
  foreach ($directory in @($profile, $local, $roaming, $temp)) {
    [void][IO.Directory]::CreateDirectory($directory)
    Assert-NoReparsePoints $directory
  }
  $reserved = @('TEMP','TMP','TMPDIR','HOME','USERPROFILE','LOCALAPPDATA','APPDATA','NDS_QUALIFICATION_SANDBOX','PATH','SYSTEMROOT','WINDIR','COMSPEC','PATHEXT')
  $allowedAdditional = @('PIP_DISABLE_PIP_VERSION_CHECK','PIP_NO_INDEX','HF_HUB_DISABLE_TELEMETRY','HF_HUB_OFFLINE','HF_HOME','HF_HUB_CACHE','TRANSFORMERS_OFFLINE','TRANSFORMERS_CACHE','TORCH_HOME','OMP_NUM_THREADS','MKL_NUM_THREADS','OPENBLAS_NUM_THREADS','CUDA_VISIBLE_DEVICES','NPM_CONFIG_CACHE','NPM_CONFIG_AUDIT','NPM_CONFIG_FUND','NPM_CONFIG_IGNORE_SCRIPTS','NDS_TEST_EXTERNAL_SENTINEL')
  foreach ($key in $Additional.Keys) {
    $normalized = ([string]$key).ToUpperInvariant()
    if ($reserved -contains $normalized) { throw 'Reserved child environment keys cannot be overridden.' }
    if ($allowedAdditional -notcontains $normalized) { throw 'Child environment key is not in the qualification allowlist.' }
  }
  $systemRoot = [Environment]::GetEnvironmentVariable('SystemRoot')
  if (-not $systemRoot) { throw 'Windows SystemRoot is required for isolated subprocesses.' }
  $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  $pathParts = @((Join-Path $systemRoot 'System32'), $systemRoot, (Join-Path $systemRoot 'System32\Wbem'))
  if ($nodeCommand -and $nodeCommand.Source) { $pathParts += Split-Path -Parent $nodeCommand.Source }
  $values = @{
    TEMP = $temp
    TMP = $temp
    TMPDIR = $temp
    HOME = $profile
    USERPROFILE = $profile
    LOCALAPPDATA = $local
    APPDATA = $roaming
    NDS_QUALIFICATION_SANDBOX = $Sandbox
    SystemRoot = $systemRoot
    WINDIR = $systemRoot
    COMSPEC = (Join-Path $systemRoot 'System32\cmd.exe')
    PATHEXT = '.COM;.EXE;.BAT;.CMD'
    PATH = ($pathParts -join ';')
  }
  foreach ($key in $Additional.Keys) { $values[$key] = [string]$Additional[$key] }
  $prefix = [IO.Path]::GetFullPath($Sandbox).TrimEnd('\') + '\'
  foreach ($key in @('TEMP','TMP','TMPDIR','HOME','USERPROFILE','LOCALAPPDATA','APPDATA')) {
    $value = [IO.Path]::GetFullPath([string]$values[$key])
    if (-not $value.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Child writable environment path escapes the qualification sandbox.' }
    Assert-NoReparsePoints $value
  }
  return $values
}

function Get-ProcessTreeWorkingSetBytes([uint32]$RootProcessId) {
  try {
    $processes = @(Get-CimInstance Win32_Process -Property ProcessId, ParentProcessId, WorkingSetSize -ErrorAction Stop)
    $processIds = New-Object 'System.Collections.Generic.HashSet[uint32]'
    [void]$processIds.Add($RootProcessId)
    $changed = $true
    while ($changed) {
      $changed = $false
      foreach ($candidate in $processes) {
        if ($processIds.Contains([uint32]$candidate.ParentProcessId) -and $processIds.Add([uint32]$candidate.ProcessId)) { $changed = $true }
      }
    }
    $total = 0L
    foreach ($candidate in $processes) { if ($processIds.Contains([uint32]$candidate.ProcessId)) { $total += [int64]$candidate.WorkingSetSize } }
    return $total
  } catch { return $null }
}

function Invoke-QualificationProcess {
  param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [Parameter(Mandatory=$true)][string[]]$ArgumentList,
    [Parameter(Mandatory=$true)][string]$WorkingDirectory,
    [Parameter(Mandatory=$true)][string]$Sandbox,
    [Parameter(Mandatory=$true)][hashtable]$Environment,
    [Parameter(Mandatory=$true)][ValidateRange(1,3600)][int]$TimeoutSeconds
  )
  Assert-QualificationSandbox $Sandbox
  if (-not [IO.File]::Exists($FilePath) -and -not [IO.Path]::IsPathRooted($FilePath)) { throw 'Executable path must be absolute.' }
  $fullWorkingDirectory = [IO.Path]::GetFullPath($WorkingDirectory)
  $relativeWorkingDirectory = [IO.Path]::GetRelativePath($script:QualificationRoot, $fullWorkingDirectory)
  if ([IO.Path]::IsPathRooted($relativeWorkingDirectory) -or $relativeWorkingDirectory -eq '..' -or $relativeWorkingDirectory.StartsWith('..' + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or $relativeWorkingDirectory.StartsWith('..' + [IO.Path]::AltDirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Subprocess working directory must remain within qualification sources.' }
  Assert-NoReparsePoints $fullWorkingDirectory
  if (-not [IO.Directory]::Exists($fullWorkingDirectory)) { throw 'Working directory is missing.' }
  $startInfo = [Diagnostics.ProcessStartInfo]::new()
  $startInfo.FileName = $FilePath
  $startInfo.WorkingDirectory = [IO.Path]::GetFullPath($WorkingDirectory)
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  foreach ($argument in $ArgumentList) { [void]$startInfo.ArgumentList.Add([string]$argument) }
  $process = [Diagnostics.Process]::new()
  $process.StartInfo = $startInfo
  $clock = [Diagnostics.Stopwatch]::StartNew()
  $started = $false
  $timedOut = $false
  $peak = 0L
  $samples = 0
  try {
    $startInfo.Environment.Clear()
    foreach ($key in $Environment.Keys) { $startInfo.Environment[[string]$key] = [string]$Environment[$key] }
    $started = $process.Start()
    if (-not $started) { throw 'Subprocess did not start.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    while (-not $process.WaitForExit(250)) {
      $sample = Get-ProcessTreeWorkingSetBytes ([uint32]$process.Id)
      if ($null -ne $sample -and $sample -gt $peak) { $peak = $sample }
      $samples++
      if ($clock.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
        $timedOut = $true
        try { $process.Kill($true) } catch {}
        if (-not $process.WaitForExit(10000)) { throw 'Timed-out process tree did not terminate within the cleanup grace period.' }
        break
      }
    }
    if ($process.HasExited) {
      $sample = Get-ProcessTreeWorkingSetBytes ([uint32]$process.Id)
      if ($null -ne $sample -and $sample -gt $peak) { $peak = $sample }
    }
    if (-not $process.WaitForExit(10000)) { throw 'Process did not exit within the bounded cleanup period.' }
    if (-not $stdoutTask.Wait(10000) -or -not $stderrTask.Wait(10000)) { throw 'Subprocess output streams did not close within the bounded cleanup period.' }
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    return [PSCustomObject]@{
      exit_code = if ($timedOut) { $null } else { $process.ExitCode }
      timed_out = $timedOut
      elapsed_s = [Math]::Round($clock.Elapsed.TotalSeconds, 3)
      process_tree_peak_working_set_bytes = $peak
      process_samples = $samples
      stdout = $stdout
      stderr = $stderr
    }
  } finally {
    if ($started -and -not $process.HasExited) {
      try { $process.Kill($true) } catch {}
      try { [void]$process.WaitForExit(10000) } catch {}
    }
    $clock.Stop()
    $process.Dispose()
  }
}

function Save-QualificationLog([string]$Name, [object]$Value) {
  if ($Name -notmatch '^cd01-[a-z0-9-]+$') { throw 'Invalid evidence log name.' }
  $directory = Join-Path $script:QualificationRoot 'logs\CD-01'
  if (Test-Path -LiteralPath $directory) { Assert-NoReparsePoints $directory }
  [void][IO.Directory]::CreateDirectory($directory)
  Assert-NoReparsePoints $directory
  $path = Join-Path $directory ($Name + '.json')
  $json = ConvertTo-Json -InputObject $Value -Depth 12 -Compress
  $bytes = [Text.UTF8Encoding]::new($false).GetBytes($json + "`n")
  $stream = [IO.File]::Open($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
  try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
  return [IO.Path]::GetRelativePath((Split-Path -Parent (Split-Path -Parent $script:QualificationRoot)), $path)
}

Export-ModuleMember -Function Get-QualificationRoot, New-QualificationSandbox, Assert-QualificationSandbox, Get-SandboxOutputPath, New-QualificationEnvironment, Invoke-QualificationProcess, Save-QualificationLog
