# Checkpoint Delta proposto — NDS-CORE-WO-001/CD-01

**Estado:** proposta para auditoria independente; não aplicada a `docs/12-checkpoint.md`.

## Estado-base confirmado

- NDS-BOOTSTRAP-001/PF-01 permanece APPROVED e integrado pela PR #10 em `c2bb0211adaf953c12f75d18be343be03cce7e93`.
- PR #11 permanece draft, alvo `main`; o Context Lock fresco da CD-01 parte da base acima e do HEAD original `49097c6eac92709a53f82a5e4e117144c0a13c19`.
- O comentário de auditoria #7174370671 foi lido integralmente e as correções F01–F04 foram implementadas/reexecutadas em `compatibility-corrections.md`, com Evidence Bundle em pt-BR.
- O checkpoint canônico segue inalterado. Nenhuma aprovação independente foi inferida; NDS-MEDIA-WO-002 continua não iniciado.

## Texto sugerido, condicionado à decisão independente

> NDS-CORE-WO-001/CD-01: correções para auditoria F01–F04 foram executadas na PR draft #11, branch `nds/core-wo-001`, sobre a base canônica `c2bb0211adaf953c12f75d18be343be03cce7e93`. Sandboxes/outputs exclusivos, testes de sentinel externo/reparse/traversal/overwrite, isolamento ambiental e encerramento de árvore passaram. Smokes reais de Kokoro/Whisper/SQLite, Remotion com ffprobe e FFmpeg/ffprobe passaram. Lockfiles foram validados sem reinstalação. Remotion 4.0.547 está qualificado gratuitamente para uso individual declarado. A origem/licença comercial da voz Kokoro `af_heart` permanece sem confirmação; `tts_models/en/ljspeech/vits` foi apenas proposto como candidato e não substituiu a arquitetura. Evidência submetida; auditoria independente pendente. Nenhuma alteração de checkpoint ou autorização de fase seguinte decorre deste Delta.

O auditor pode decidir APPROVED, CORRECTION REQUIRED ou BLOCKED conforme o Work Order, considerando explicitamente o gate comercial de voz. Só após parecer independente APPROVED e autorização aplicável outra pessoa pode atualizar o checkpoint canônico. Até então: sem promoção, merge, produto, MEDIA ou publicação.
