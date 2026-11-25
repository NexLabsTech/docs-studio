# Checkpoint Delta proposto — NDS-CORE-WO-001

**Estado:** proposta para auditoria independente; não aplicada a `docs/12-checkpoint.md`.

## Estado-base confirmado

- NDS-BOOTSTRAP-001/PF-01 permanece APPROVED e integrado pela PR #10 em `c2bb0211adaf953c12f75d18be343be03cce7e93`.
- A `main` ainda aponta para esse SHA; o Context Lock fresco desta WO parte desse commit.
- O checkpoint canônico ainda diz que a qualificação CORE local não foi executada. Esse registro permanece intacto até parecer independente.

## Texto sugerido, condicionado à decisão do auditor

> NDS-CORE-WO-001: execução local Windows concluída no HEAD `<HEAD-DA-PR>`, Evidence Bundle publicado na PR `<PR>`, CI gratuito `<status/URL>`. AC01–AC10 e limitações estão evidenciados. Estado sugerido: **evidência submetida, aguardando auditoria independente**. PF-01 continua APPROVED. Nenhuma aprovação, promoção, merge, implementação do produto, publicação ou início de NDS-MEDIA-WO-002 decorre deste texto.

O auditor independente deve substituir o estado sugerido por APPROVED, CORRECTION REQUIRED ou BLOCKED conforme o Work Order. Somente após parecer APPROVED e autorização aplicável outra pessoa pode atualizar o checkpoint canônico. Até lá, a fase seguinte continua sem autorização.
