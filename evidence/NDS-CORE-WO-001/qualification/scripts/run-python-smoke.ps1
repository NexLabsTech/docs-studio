param([switch]$Offline = $true)
$ErrorActionPreference = 'Stop'
$module = Join-Path $PSScriptRoot 'QualificationSandbox.psm1'
Import-Module $module -Force
$qualificationRoot = Get-QualificationRoot
$runtimeRoot = Join-Path $env:TEMP 'nds-core-wo-001-runtime'
$python = Join-Path $runtimeRoot 'python-venv\Scripts\python.exe'
$smoke = Join-Path $PSScriptRoot '..\python\smoke.py'
if (-not [IO.File]::Exists($python)) { throw 'The existing isolated Python environment is missing.' }
if (-not [IO.File]::Exists($smoke)) { throw 'The qualification smoke source is missing.' }

$sandbox = New-QualificationSandbox -Purpose 'python'
$cacheRoot = Join-Path $runtimeRoot 'hf-cache'
$additional = @{
  HF_HOME = $cacheRoot
  HF_HUB_CACHE = (Join-Path $cacheRoot 'hub')
  HF_HUB_OFFLINE = '1'
  HF_HUB_DISABLE_TELEMETRY = '1'
  TRANSFORMERS_OFFLINE = '1'
  TRANSFORMERS_CACHE = (Join-Path $runtimeRoot 'transformers-cache')
  TORCH_HOME = (Join-Path $runtimeRoot 'torch-cache')
  OMP_NUM_THREADS = '4'
  MKL_NUM_THREADS = '4'
  OPENBLAS_NUM_THREADS = '4'
  CUDA_VISIBLE_DEVICES = ''
}
$environment = New-QualificationEnvironment -Sandbox $sandbox -Additional $additional
$result = Invoke-QualificationProcess -FilePath $python -ArgumentList @($smoke, 'all') -WorkingDirectory $qualificationRoot -Sandbox $sandbox -Environment $environment -TimeoutSeconds 300
if ($result.timed_out) { throw 'Python qualification exceeded its 300 second limit; its process tree was terminated.' }
if ($result.exit_code -ne 0) { throw "Python qualification failed with exit code $($result.exit_code)." }
$jsonLine = ($result.stdout -split '\r?\n' | Where-Object { $_.TrimStart().StartsWith('{') } | Select-Object -Last 1)
if (-not $jsonLine) { throw 'Python qualification returned no JSON evidence.' }
$smokeResult = $jsonLine | ConvertFrom-Json
if (-not $smokeResult.tts_asr_hash_chain_match -or -not $smokeResult.asr.timestamps_monotonic -or -not $smokeResult.asr.timestamps_within_audio -or -not $smokeResult.asr.expected_transcript_match) { throw 'TTS/ASR linkage or timestamp assertions failed.' }
$diskBytes = 0L
Get-ChildItem -Force -LiteralPath $sandbox -File -Recurse | ForEach-Object { $diskBytes += [int64]$_.Length }
$evidence = [ordered]@{
  command = 'python smoke.py all'
  exit_code = $result.exit_code
  timeout_seconds = 300
  timed_out = $false
  elapsed_s = $result.elapsed_s
  process_tree_peak_working_set_bytes = $result.process_tree_peak_working_set_bytes
  process_samples = $result.process_samples
  memory_measurement = 'WMI WorkingSetSize soma da árvore do processo; amostragem a cada 250 ms'
  output_bytes_in_sandbox = $diskBytes
  model_access = 'snapshots fixados já em cache; HF_HUB_OFFLINE=1; sem download nem chamada de API no código do smoke'
  sandbox_validation = 'diretório de execução novo e exclusivo sob qualification/.runtime/runs'
  tts_asr_hash_chain_match = $smokeResult.tts_asr_hash_chain_match
  fixture = $smokeResult.fixture
  tts = $smokeResult.tts
  asr = $smokeResult.asr
  sqlite = $smokeResult.sqlite
}
$logName = 'cd01-python-smoke-' + [Guid]::NewGuid().ToString('N')
$logRelative = Save-QualificationLog -Name $logName -Value $evidence
$evidence | Add-Member -NotePropertyName evidence_log -NotePropertyValue $logRelative
$evidence | ConvertTo-Json -Depth 12 -Compress
