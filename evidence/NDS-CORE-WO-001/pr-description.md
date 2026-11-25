## Pedido de auditoria independente

Submeto NDS-CORE-WO-001 — fase 1 de qualificação local Windows — para auditoria independente. PF-01 já está APPROVED e integrada pela PR #10; esta PR não repete bootstrap nem implementa o produto.

PR draft #11, base `main` em `c2bb0211adaf953c12f75d18be343be03cce7e93`. Commit de qualificação `40ddb1e42da6eb675b6801721f8abc6191c49dfb`. GitHub Actions run `45696205047` (`docs-validation`) e os checks Socket preexistentes passaram no SHA de qualificação.

O Evidence Bundle em `evidence/NDS-CORE-WO-001/evidence-bundle.md` mapeia AC01–AC10, licenças/custos, smoke tests, benchmarks, hashes e o Checkpoint Delta proposto. As mudanças estão limitadas a documentação e ferramentas de qualificação sob `evidence/NDS-CORE-WO-001/`.

Peço revisão independente do Context Lock, compatibilidade/licenças, reprodução dos smokes, segurança/custos e critérios de aceitação. O checkpoint canônico permanece inalterado. Esta PR deve continuar draft até a auditoria; sem merge, promoção de checkpoint, implementação, início de NDS-MEDIA-WO-002 ou publicação de vídeo.
