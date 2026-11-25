# Evidence Bundle — NDS-CORE-WO-001

**Idioma:** português brasileiro. **Data:** 25/11/2026. **Estado:** evidência submetida para auditoria independente; este arquivo não declara aprovação nem altera o checkpoint canônico.

## Identificação e Context Lock

- Repositório: `NexLabsTech/docs-studio`; branch `nds/core-wo-001`.
- Base canônica verificada: `main` = `c2bb0211adaf953c12f75d18be343be03cce7e93`, commit de merge da PR #10. PR #10 está MERGED. PF-01 não foi repetida.
- Commit de qualificação: `40ddb1e42da6eb675b6801721f8abc6191c49dfb`; PR draft #11: [NDS-CORE-WO-001](https://github.com/NexLabsTech/docs-studio/pull/11), base `main` em `c2bb0211adaf953c12f75d18be343be03cce7e93`.
- CI no commit de qualificação exato: [GitHub Actions run 45696205047](https://github.com/NexLabsTech/docs-studio/actions/runs/45696205047), `Documentation CI / docs-validation` SUCCESS, job 139494137125. `Socket Security: Project Report` e `Pull Request Alerts` também SUCCESS; são integrações já existentes no repositório público.
- A PR permanece draft e bloqueada para merge. O commit final deste bundle é documental e dispara nova verificação; o resultado da HEAD mais recente fica visível na aba Checks da PR #11 e no corpo atualizado da PR.
- Context Lock: `context-lock.md`, hashes SHA-256 dos documentos de fonte no base canônico.
- Fonte original não foi modificada. Todas as alterações desta WO estão sob `evidence/NDS-CORE-WO-001/`.

## Escopo, ambiente e alterações

O trabalho qualifica ferramentas e dependências localmente no Windows; contém documentação, scripts de smoke, lockfiles, uma fixture PNG sintética e logs. Não há implementação do produto, UI, pipeline editorial, episódio, modelo, WAV, MP4 ou upload versionado. Inventário sanitizado: `windows-inventory.md` e `qualification/logs/windows-inventory.json`. Ambiente isolado e limitações: `license-cost-security.md`; resultados: `benchmarks.md`.

## Matriz AC01–AC10

| AC | Estado | Evidência |
|---|---|---|
| AC01 | PASS | `context-lock.md`; base e fingerprints; branch criada a partir do SHA confirmado. |
| AC02 | PASS | `windows-inventory.md`; `qualification/logs/windows-inventory.json`; modelo local `gpt-6-luna`, esforço `max`. |
| AC03 | PASS | `qualification/remotion/`; fixture PNG e 3 logs `qualification/logs/remotion-remotion-warm-*.json`; render 10 s verificado por ffprobe. |
| AC04 | PASS | Kokoro en-US e Faster Whisper CPU/int8; logs `qualification/logs/tts-offline-final-tts-*.json` e `whisper-offline-final-whisper-*.json`. |
| AC05 | PASS | `qualification/logs/ffmpeg-smoke-final.json` e `sqlite-offline-final-sqlite.json`; codecs/streams, transação e reabertura confirmados. |
| AC06 | PASS | Sem prova de direito ImageGen sem custo, então não chamado; fixture de importação PNG sintética testada em Remotion. |
| AC07 | PASS | `benchmarks.md`; três renderizações e três repetições de áudio/transcrição; tempos, picos de memória, hashes e uso de disco registrados. |
| AC08 | PASS | `license-cost-security.md`, inventários de licença, pins, correções de compatibilidade, nenhum serviço pago/chamada paga; rollback e limites documentados. |
| AC09 | PASS | Commit `40ddb1e`; push para `nds/core-wo-001`; PR draft #11; workflow gratuito run 45696205047 SUCCESS no SHA exato. Checks Socket preexistentes também passaram. |
| AC10 | PASS | Este bundle em pt-BR, `benchmarks.md`, `compatibility-corrections.md`, hashes/logs sanitizados e `checkpoint-delta-proposed.md`; nenhum HIGH/CRITICAL conhecido. O parecer independente continua pendente por desenho. |

## Comandos e verificações concluídos localmente

- `python scripts/validate_docs.py --self-test` — PASS, 1 teste.
- `python scripts/validate_docs.py` — PASS, 37 caminhos requeridos, zero erros.
- `pip check` — PASS, sem dependências quebradas.
- `npm ls --depth=0` — PASS: Remotion CLI/Remotion 4.0.547, React/React DOM 19.3.1.
- Remotion: 3 renders de 10 s, todos exit 0, ffprobe H.264 1920×1080/30 fps/300 frames.
- Kokoro: 3 execuções offline, seed 42, hash de saída repetível; Faster Whisper: 3 execuções offline, 7 timestamps monotônicos.
- FFmpeg+ffprobe: encode/mix sintéticos de 5 s, ambos exit 0. SQLite: create/read/rollback/commit/reopen passou.
- Varredura de evidências por caminhos pessoais e padrões comuns de tokens: sem correspondências. Não foram versionados modelos, mídia nem credenciais.
- `git diff --cached --check` — PASS. CI remoto no SHA `40ddb1e`: run 45696205047 SUCCESS; checks visíveis na [PR #11](https://github.com/NexLabsTech/docs-studio/pull/11).

## Licenças, custo, erros e achados residuais

- Nenhum serviço/API/assinatura de custo adicional foi usado. O workflow existente usa `ubuntu-latest`; para o repositório público, runners padrão GitHub-hosted são gratuitos. Os checks Socket já existentes passaram; a tabela oficial lista plano Free de US$0 e repositórios públicos ilimitados. Não foi adicionada workflow paga, runner self-hosted ou alteração de cobrança.
- ImageGen ficou sem verificação de entitlement sem custo e foi substituído pelo fallback autorizado. FFmpeg preexistente é build GPL; uso local e sem redistribuição. eSpeak NG é GPL-3.0-or-later, sem distribuição; proveniência de treinamento da voz Kokoro permanece incerta. Esses limites são futuros, não alteram o smoke local.
- PyAV 19.0.2 era incompatível com Faster Whisper 1.2.1; `av==18.1.1` corrigiu. Um defeito do harness que contaminava TEMP do chamador foi corrigido. TTS recebeu seed determinística após hash variar sem seed. Detalhes: `compatibility-corrections.md`.
- Não há achado conhecido HIGH/CRITICAL. Limitações MEDIUM a revisar antes de produto/redistribuição: licença GPL do eSpeak NG, proveniência da voz, elegibilidade de Remotion fora de avaliação e orçamento de latência do produto ainda não definido.

## Checkpoint Delta proposto e decisão

Ver `checkpoint-delta-proposed.md`. Não foi editado `docs/12-checkpoint.md`; o Delta é apenas proposta. O auditor independente decide APPROVED, CORRECTION REQUIRED ou BLOCKED. Até o parecer, não promover checkpoint, não fazer merge, não implementar o produto, não iniciar NDS-MEDIA-WO-002 e não publicar vídeo.
