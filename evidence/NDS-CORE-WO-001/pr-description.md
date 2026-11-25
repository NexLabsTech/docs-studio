## Auditoria independente — NDS-CORE-WO-001/CD-01

Submeto exclusivamente as correções do comentário de auditoria #7174370671 na PR #11. A PR continua draft; base canônica `main`=`c2bb0211adaf953c12f75d18be343be03cce7e93`. O head de origem revisado antes deste CD-01 era `49097c6eac92709a53f82a5e4e117144c0a13c19`; o HEAD corretivo corrente e a execução CI desse mesmo SHA podem ser conferidos na aba [Checks](https://github.com/NexLabsTech/docs-studio/pull/11/checks).

### Resultado dos findings

- **F01 — corrigido:** paths novos e confinados, rejeição de traversal/UNC/reparse/destino existente, sentinel externo preservado, SQLite exclusivo, render/encode sem overwrite, ambiente de subprocesso limpo e allowlisted, timeout e encerramento da árvore.
- **F02 — corrigido para o escopo CD-01:** licença exata Remotion 4.0.547 qualificada para uso individual gratuito inclusive comercial, conforme escopo declarado pelo usuário. A proveniência da voz Kokoro `af_heart` não é confirmada pelo Apache-2.0 dos pesos nem pelo card; a voz não está liberada para uso comercial. `tts_models/en/ljspeech/vits` foi proposto como possível alternativa gratuita, sem instalar ou alterar arquitetura. Ver `license-cost-security.md`.
- **F03 — corrigido:** ffprobe executado sobre MP4s reais com asserts; hash TTS de saída igual ao ASR de entrada, texto e timestamps assertados; resumo RAM corrige que TTS é maior que Remotion.
- **F04 — corrigido:** Python lock/freeze e npm `ci --dry-run`, `npm ls`, integrities/origens e versões verificadas usando venv, `node_modules` e caches já instalados; zero reinstalação/download.

### Evidências

`evidence/NDS-CORE-WO-001/evidence-bundle.md` e `context-lock.md` registram AC01–AC10, Source Check fresco, comandos, hashes, logs, desempenho, limitações e Checkpoint Delta proposto. Smokes locais de TTS/ASR/SQLite, Remotion 10 s e FFmpeg 5 s passaram; logs CD-01 em `qualification/logs/CD-01/`. Custos adicionais: US$ 0.

### Pedido e limites

Peço auditoria independente em português brasileiro de F01–F04 e do gate comercial de voz. A proveniência comercial Kokoro permanece não comprovada, e a alternativa é só uma proposta para decisão do owner/auditor. O checkpoint canônico permanece inalterado. Sem bypass, merge, promoção de checkpoint, implementação do produto, início de NDS-MEDIA-WO-002 ou publicação de vídeos.
