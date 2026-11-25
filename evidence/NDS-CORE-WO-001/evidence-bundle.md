# Evidence Bundle — NDS-CORE-WO-001

**Idioma:** português brasileiro. **Data:** 25/11/2026. **Estado:** evidência submetida para auditoria independente; este arquivo não declara aprovação nem altera o checkpoint canônico.

## Identificação e Context Lock

- Repositório: `NexLabsTech/docs-studio`; branch `nds/core-wo-001`.
- Base canônica verificada: `main` = `c2bb0211adaf953c12f75d18be343be03cce7e93`, commit de merge da PR #10. PR #10 está MERGED. PF-01 não foi repetida.
- HEAD/PR/CI: preencher após commit, push e criação da PR draft; registrar o SHA e o run/check real, sem presumir sucesso.
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
| AC09 | BLOCKED | Ainda depende do commit/push/PR e do CI da branch; preencher com estado real após as verificações remotas. |
| AC10 | BLOCKED | Este bundle e o Checkpoint Delta proposto estão redigidos; completar o vínculo de HEAD/PR/CI e estado candidato após o CI. |

## Comandos e verificações concluídos localmente

- `python scripts/validate_docs.py --self-test` — PASS, 1 teste.
- `python scripts/validate_docs.py` — PASS, 37 caminhos requeridos, zero erros.
- `pip check` — PASS, sem dependências quebradas.
- `npm ls --depth=0` — PASS: Remotion CLI/Remotion 4.0.547, React/React DOM 19.3.1.
- Remotion: 3 renders de 10 s, todos exit 0, ffprobe H.264 1920×1080/30 fps/300 frames.
- Kokoro: 3 execuções offline, seed 42, hash de saída repetível; Faster Whisper: 3 execuções offline, 7 timestamps monotônicos.
- FFmpeg+ffprobe: encode/mix sintéticos de 5 s, ambos exit 0. SQLite: create/read/rollback/commit/reopen passou.
- Varredura de evidências por caminhos pessoais e padrões comuns de tokens: sem correspondências. Não foram versionados modelos, mídia nem credenciais.
- `git diff --check` e CI gratuito serão registrados após commit/push.

## Licenças, custo, erros e achados residuais

- Nenhum serviço/API/assinatura de custo adicional foi usado. O workflow existente usa `ubuntu-latest`; para o repositório público, runners padrão GitHub-hosted são gratuitos. Não foi adicionada workflow paga ou runner self-hosted.
- ImageGen ficou sem verificação de entitlement sem custo e foi substituído pelo fallback autorizado. FFmpeg preexistente é build GPL; uso local e sem redistribuição. eSpeak NG é GPL-3.0-or-later, sem distribuição; proveniência de treinamento da voz Kokoro permanece incerta. Esses limites são futuros, não alteram o smoke local.
- PyAV 19.0.2 era incompatível com Faster Whisper 1.2.1; `av==18.1.1` corrigiu. Um defeito do harness que contaminava TEMP do chamador foi corrigido. TTS recebeu seed determinística após hash variar sem seed. Detalhes: `compatibility-corrections.md`.
- Não há achado conhecido HIGH/CRITICAL. Limitações MEDIUM a revisar antes de produto/redistribuição: licença GPL do eSpeak NG, proveniência da voz, elegibilidade de Remotion fora de avaliação e orçamento de latência do produto ainda não definido.

## Checkpoint Delta proposto e decisão

Ver `checkpoint-delta-proposed.md`. Não foi editado `docs/12-checkpoint.md`; o Delta é apenas proposta. O auditor independente decide APPROVED, CORRECTION REQUIRED ou BLOCKED. Até o parecer, não promover checkpoint, não fazer merge, não implementar o produto, não iniciar NDS-MEDIA-WO-002 e não publicar vídeo.
