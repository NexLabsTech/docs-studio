# Correções e regressões — NDS-CORE-WO-001/CD-01

O parecer é o comentário de auditoria #7174370671 na PR #11, consultado integralmente nesta tarefa. Este documento acompanha apenas CD-01; não altera o Work Order nem arquivos canônicos.

## F01 — confinamento, sobrescrita, ambiente e timeout

- `qualification/scripts/QualificationSandbox.psm1` fixa a raiz da qualificação e cria um diretório aleatório `run-<purpose>-<guid>` como filho direto de `.runtime/runs`. Rejeita componente reparse em qualquer caminho de sandbox/saída/cwd, paths absolutos, drive/UNC, componentes vazios, `.`/`..` e destinos que já existem. O cwd de cada subprocesso tem de ser a raiz de qualificação ou um descendente dela.
- Python valida novamente o sandbox sem resolver symlinks antes da checagem, e cria fixture/WAV/SQLite com `open(..., "xb")`. SQLite nunca remove DB existente. Remotion recebe apenas o arquivo novo dentro do sandbox, sem `--overwrite`; FFmpeg usa `-n`.
- `ProcessStartInfo.Environment` é limpo antes de criar o filho. O harness injeta só variáveis de sistema mínimas, TEMP/TMP/HOME/USERPROFILE/APPDATA novos e nomes adicionais numa allowlist explícita. `test-process-isolation.ps1` comprova que um sentinel privado do pai não atravessa a fronteira, que variáveis do pai não mudam em sucesso/falha/timeout e que nome ambiental não autorizado é recusado.
- Cada processo tem timeout explícito. Timeout mata a árvore via `Process.Kill(entireProcessTree: true)` e espera até 10 s pelo encerramento/fechamento dos streams; não há espera infinita depois do timeout. O teste cria um processo filho e confirma que também encerrou.
- `test-negative-outputs.ps1` e `python/test_sandbox.py` testam traversal, caminho absoluto, UNC, junction Windows (reparse point), destino existente e path legado para DB. SHA-256 de sentinel externo e arquivo existente permanece igual.
- Evidências: `qualification/logs/CD-01/cd01-negative-paths-0ec7e1d3bc32448f88d410ddcd47ee1a.json` e `cd01-process-tests-06a93721c27c4a839acc18d29ed84f28.json`. Resultado: PASS.

## F02 — licenças e proveniência

- A licença exata Remotion 4.0.547 foi lida da tag e permite uso gratuito individual, inclusive criação comercial de vídeo/imagem. Ela não implica que uma eventual entidade empresa que use o produto também seja elegível. Nenhum aceite ou compra foi executado.
- Apache-2.0 de Kokoro cobre os pesos, mas o card não mapeia fontes por voz. `af_heart` continua sem resposta de proveniência qualificada em issue #376. O smoke en-US comprova capacidade técnica local, não direitos comerciais da voz. Não liberar áudio Kokoro comercial até documentação adicional.
- Como a lacuna exige opção futura, documentamos Coqui `tts_models/en/ljspeech/vits` como candidato gratuito: catálogo lista pesos Apache-2.0 e o dataset upstream declara gravações/metadata em domínio público. Não foi baixado, instalado, testado nem adotado. A decisão arquitetural fica pendente do auditor/owner; compatibilidade Windows/Python e versão/hash ainda teriam de ser qualificados.
- eSpeak NG continua identificado como GPL-3.0-or-later; sem redistribuição de binário.
- Detalhes e fontes: `license-cost-security.md`. Resultado: Remotion individual PASS para o escopo declarado; proveniência Kokoro BLOQUEADA para uso comercial; alternativa apenas proposta.

## F03 — ffprobe real, hash TTS-ASR, timestamps e RAM

- Remotion agora executa ffprobe sobre o MP4 que acabou de renderizar, com `-count_frames`, e falha se H.264, 1920×1080, 30/1, 300 frames, duração 10 s ±0,02 ou tamanho não corresponderem. O log CD-01 guarda JSON real do ffprobe e SHA-256 do MP4.
- FFmpeg executa encode com `-n`, depois ffprobe no MP4 real. Assertiva duração 5 s ±0,05, H.264 1280×720/30, AAC 48 kHz mono e tamanho real.
- TTS/ASR roda no mesmo diretório de execução novo: o ASR lê `tts.wav` exato. O harness compara hash de saída TTS e hash de entrada Whisper, verifica frase esperada, 7 timestamps monotônicos e cada fim <= duração + 50 ms.
- A memória passou a ser descrita pela mesma métrica observável: soma do `WorkingSetSize` da árvore WMI, amostrada a cada 250 ms. No CD-01, TTS 1.415.843.840 bytes > Remotion 1.212.628.992 bytes; FFmpeg terminou com uma amostra e seu valor é apenas limite inferior. O relatório anterior dizia que Remotion era o maior consumo, afirmação corrigida em `benchmarks.md`.
- Logs: `cd01-python-smoke-79164bc944b74d4dbe26084a60af2691.json`, `cd01-remotion-probe-bb52f39615204cd883b8627c68b516f4.json` e `cd01-ffmpeg-probe-90969cb1a72d4833962738690652d567.json`. Resultado: PASS.

## F04 — reprodução por lockfile sem reinstalar

- `requirements-lock.txt` foi avaliado com pip dry-run, `--no-index --no-deps`, `pip check` e `pip freeze --all` no venv isolado que já existia. Freeze correspondeu aos pins; nenhum download ou reinstall.
- `package-lock.json` foi verificado com `npm ci --dry-run --ignore-scripts --no-audit --no-fund --prefer-offline` e `npm ls --depth=0`. Dry-run não removeu/reinstalou o tree existente; lifecycle scripts desativados. As quatro dependências diretas instaladas foram comparadas aos pins de `package.json`; 291 pacotes remotos têm integrity e usam o registry oficial.
- Os caches locais existentes foram reutilizados; comandos não habilitam scripts de terceiros e não fizeram requests de API pagos. Não houve instalação global.
- Logs finais: `cd01-python-lock-b5e70912a68d446b90d44fc023019ad7.json` e `cd01-npm-lock-f591a2f1a6d2435d961841ebe3024f9b.json`. O comparador Python confirma 101/101 distribuições instaladas, nenhuma extra/ausente/diferente e hash do wheel por URL direta. Resultado: PASS.

## Compatibilidade já corrigida antes de CD-01

`faster-whisper==1.2.1` falhou com `av==19.0.2` por argumento removido. A versão fixada `av==18.1.1` passa `pip check` e inferência real. Os smoke scripts mantêm Python, modelos e Node/npm em instalações isoladas. Durante CD-01, uma consulta PowerShell encontrou dois `node.exe` e retornou array; o runner agora escolhe explicitamente o primeiro executável encontrado e repetiu render/ffprobe com sucesso. Isso não alterou a versão fixada do Node ou das dependências.
