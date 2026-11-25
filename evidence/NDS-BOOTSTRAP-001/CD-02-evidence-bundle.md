# Evidence Bundle — NDS-CORE-WO-001/PF-01 · NDS-BOOTSTRAP-001/CD-02

**Data:** 2026-11-25 (America/Sao_Paulo)
**Escopo executado:** somente preflight administrativo remoto no repositório autorizado. Sem qualificação local, instalações, implementação de produto, publicação, merge ou promoção do checkpoint.
**Estado deste registro:** candidato; atualizar após novo CI no HEAD final e leitura efetiva das regras.

## Identidade e Context Lock

- Repositório: [NexLabsTech/docs-studio](https://github.com/NexLabsTech/docs-studio), público, main como branch padrão.
- Execução: PR #10, nds/bootstrap-001, base main em 4f2439bd0d9fe342ccd776d45f62cffc3a320dc6.
- HEAD inicialmente solicitado e inspecionado: 75fb78eef157f966ca0b969ed4188a741360c47a.
- HEAD final deste bundle e URL/ID do novo run: PENDENTE do commit de evidências e do evento pull_request.
- PR #10 permanece aberto e Draft; não houve merge.
- Identidade CLI confirmada: NexLabsTech; permissão REST no repositório: admin=true, push=true.
- A página autenticada de configurações da conta mostrou o e-mail primário como **Verified**. Nenhum e-mail de verificação foi lido por automação e nenhum código de autenticação foi retido.
- Checkout isolado limpo no início: C:\Users\csn19\AppData\Local\Temp\docs-studio-nds-bootstrap-001-phase0; HEAD exato acima; Python 3.12.10; GitHub CLI 2.98.0; shell Windows PowerShell.
- Impressões SHA-256 dos arquivos de contexto no HEAD inspecionado:
  - AGENTS.md — 9C8FFE8A681EBC652D553070281D32962336022C66C213155A8B2B26B1F55C4A
  - PROMPT-CODEX.md — 4D2CF0F492F14928614FDD8EBA356F9521A83E373CC480C948CBB22B263AD2FC
  - docs/12-checkpoint.md — B973236E8A8BBF1FB0A039FD70C49A04EE6A6A5C3AA632C097B84CA132A92896
  - docs/11-decisions.md — BA6A8333F9D2869F52E4EE1266FA6D9DC55F192B02C71FEA24B5AF9847762BEB
  - docs/03-scope.md — F082151DB232ED9B77AAB40A50435CB9C7E761E1117B46D2BD60F7F80ED08533
  - docs/10-definition-of-done.md — 33555D6DDAAD9B0F4D8BEB41328C27BC61E1DD38D5E0F89F4E1F9B950E079119
  - docs/04-architecture.md — E504F5D8A6447CCF2F82F98730E78499C3B16E39663324F6484808E89144E4FF
  - docs/02-requirements.md — C9B53B8CCD299EF4DE0BE3BCA3622325BFCB7A4758F1B4A0A648A480D1697825
  - docs/19-governance.md — B2E15F3E23115EAFDB06BA55615116A19A7D0E4702713FBCC481B8DBCA159975
  - work-orders/NDS-CORE-WO-001.md — C5813231725C5BC25C423D2B7EC78FFC2B1BB105D97620B8FD72EE5B315B2689
  - .github/governance/main-ruleset.json — DB58D1095C7EBC14E7648CA2E71F2EF80504E1A822C0BDD37FC8C694F2D4CE79
  - .github/workflows/docs-validation.yml — BF117D70481846A809F0DF94D86719F1DA1F6AD2216212197EE39691949903A5

## Configuração administrativa e custo

- GitHub Actions foi mantido habilitado e configurado para aceitar somente actions locais (allowed_actions=local_only) com exigência de pin por SHA; a workflow atual não usa uses:, ações de terceiros, cache, artefatos, secrets ou serviços externos.
- Permissões padrão da workflow: contents: read; aprovação de PRs via GITHUB_TOKEN: desabilitada.
- A workflow usa ubuntu-latest, timeout de 5 minutos, validação somente de repositório público e sem passos de instalação. O repositório foi lido como público antes de iniciar runs.
- Elegibilidade sem custo adicional: [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners) e [billing de Actions](https://docs.github.com/en/actions/concepts/billing-and-usage) documentam runners padrão gratuitos para repositórios públicos; [regras disponíveis](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets) documentam rulesets públicos no plano gratuito. Não foi habilitado runner maior, artefato, cache, assinatura ou plano pago.
- Leitura autenticada antes do gate: API de rulesets retornou []; proteção legada de main retornou HTTP 404 Branch not protected.
- **Ainda não aplicado:** ruleset de main. A receita .github/governance/main-ruleset.json só será aplicada depois de um docs-validation genuíno passar no HEAD atual. Sem atores de bypass.

## Validações e CI

Comandos locais autorizados pela fase 0; executados inicialmente no checkout limpo do SHA 75fb78eef157f966ca0b969ed4188a741360c47a, com Python 3.12.10, e repetidos após a inclusão das evidências:

| Comando | Código | Saída observada |
|---|---:|---|
| python --version | 0 | Python 3.12.10 |
| python scripts/validate_docs.py --self-test | 0 | 1 teste; OK |
| python scripts/validate_docs.py | 0 | docs-validation: PASS; 37 required paths; 0 errors |

Os dois runs iniciais no SHA solicitado, [run #3](https://github.com/NexLabsTech/docs-studio/actions/runs/45644382002) e [run #4](https://github.com/NexLabsTech/docs-studio/actions/runs/45644401574), terminaram startup_failure, com jobs=[], sem check-run docs-validation; ambos têm path=BuildFailed/evento exibido como desconhecido no UI. A tentativa de retry do #4 foi recusada (run 45644401574 cannot be rerun; This workflow run cannot be retried). Nenhum deles é PASS. A edição deste bundle sincronizará a PR para um novo evento; registrar aqui o run novo e seu SHA após resultado real.

Saídas de comandos são registradas neste bundle; não foi criado log com credenciais. O verificador local cobre caminhos e consistência documental, não prova execução hosted, semântica completa, licenças ou segurança.

## Matriz de aceite do NDS-CORE-WO-001

| AC | Estado | Evidência / explicação |
|---|---|---|
| AC01 | PASS — candidato | Source Pack e documentação canônica versionados na branch; source-check.md, hashes acima e PR #10. Ainda não integrado nem promovido. |
| AC02 | BLOCKED / fora do PF-01 | Inventário completo de Windows, hardware, RAM/disco e disponibilidade de modelo/effort não foi executado. |
| AC03 | BLOCKED / fora do PF-01 | Elegibilidade/termos e smoke do Remotion não foram executados. |
| AC04 | BLOCKED / fora do PF-01 | Kokoro e Faster Whisper não foram instalados nem exercitados. |
| AC05 | BLOCKED / fora do PF-01 | FFmpeg, ffprobe e SQLite locais não foram qualificados. |
| AC06 | BLOCKED / fora do PF-01 | ImageGen não foi chamado; fallback local não foi qualificado. |
| AC07 | BLOCKED / fora do PF-01 | Nenhum benchmark local foi executado. |
| AC08 | BLOCKED para o WO completo; PASS para elegibilidade inicial da CI | Repositório público, runner padrão gratuito e permissões mínimas foram confirmados. Checklist completo de dependências/licenças e CI verde ainda pendentes. |
| AC09 | BLOCKED | Diff de documentação/evidência; aguardando novo check verde no HEAD corrente e leitura efetiva da proteção. Não há implementação de produto. |
| AC10 | PASS para este bundle candidato | Bundle e proposta de delta presentes; dependências técnicas e auditoria independente continuam pendentes. |

## Mudanças, risco e pendências

- Mudanças desta entrega: registrar o preflight real e a proposta de delta sob evidence/NDS-BOOTSTRAP-001/; complementar docs/19-governance.md com leitura CD-02. Nenhum código de produto.
- Risco/bloqueador atual: main sem proteção e sem ruleset; CI hosted ainda sem execução válida. A evidência permanece candidata até novo run, aplicação/read-back das regras e auditoria independente.
- Achados: **MEDIUM** — governança efetiva de main ainda não ativa; **MEDIUM** — docs-validation ainda sem check válido. Nenhum achado HIGH/CRITICAL identificado no escopo administrativo limitado; isso não equivale a auditoria de segurança.
- Rollback: remover o ruleset por seu ID caso o read-back revele incompatibilidade; a policy Actions anterior poderá ser restaurada para allowed_actions=all e sha_pinning_required=false se necessária para voltar ao estado anterior. Nenhum dado de produto ou dependência foi alterado.
- Segredos: varredura determinística do diff staged neste commit — PASS para cabeçalhos de chave privada, tokens GitHub, chaves AWS AKIA e tokens OpenAI; git diff --cached --check exit 0. O scan é heurístico e não prova ausência universal de segredos.
- Próximo gate: obter CI verde no SHA final; aplicar e ler de volta ruleset sem bypass, conferindo também proteção efetiva; atualizar a evidência; parar para auditoria independente. Sem merge, aprovação própria ou fase 1.

## Delta proposto

Ver CD-02-checkpoint-delta.md. O checkpoint canônico continua sem promoção automática.
