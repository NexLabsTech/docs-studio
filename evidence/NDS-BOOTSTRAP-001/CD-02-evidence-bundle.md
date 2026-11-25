# Evidence Bundle — NDS-CORE-WO-001/PF-01 · NDS-BOOTSTRAP-001/CD-02

**Data:** 2026-11-25 (America/Sao_Paulo)
**Escopo:** preflight administrativo remoto e evidência de bootstrap. Nenhuma qualificação local, instalação, implementação de produto, publicação, merge ou promoção do checkpoint.
**Estado:** candidato para auditoria independente; a revisão final deste arquivo gera um novo HEAD e deve receber CI verde nesse HEAD antes do envio ao auditor.

## Identidade e Context Lock

- Repositório: [NexLabsTech/docs-studio](https://github.com/NexLabsTech/docs-studio), público; branch padrão main.
- PR #10 aberto em Draft, nds/bootstrap-001 → main; base SHA 4f2439bd0d9fe342ccd776d45f62cffc3a320dc6.
- SHA exato inicialmente solicitado e inspecionado: 75fb78eef157f966ca0b969ed4188a741360c47a.
- A versão deste bundle é carregada pelo commit atual da branch nds/bootstrap-001; seu SHA e o check mais recente são visíveis em [PR #10 / checks](https://github.com/NexLabsTech/docs-studio/pull/10/checks). O relatório final registra o HEAD e o run dessa verificação.
- SHA com CI hosted válido antes desta última atualização de evidência: e4ad8410085dc7e9002fa79414f4854caade08b0; [run 45671724553](https://github.com/NexLabsTech/docs-studio/actions/runs/45671724553), evento pull_request, job docs-validation 139408493611, sucesso.
- Identidade CLI: NexLabsTech; permissão lida via API no repositório: admin=true, push=true.
- A página autenticada de configurações da conta mostrou o e-mail primário como Verified. Nenhum e-mail foi lido por automação; nenhum código de autenticação foi salvo no checkout ou neste bundle.
- Checkout isolado: C:\Users\csn19\AppData\Local\Temp\docs-studio-nds-bootstrap-001-phase0; inicialmente limpo no SHA solicitado. Python 3.12.10, GitHub CLI 2.98.0, shell Windows PowerShell.
- Hashes SHA-256 de contexto no SHA inicialmente inspecionado:
  - README.md — 30301FA303BFC20A2796811924481201AE21C9391694D168AF1AFC568F5CD187
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

## Administração do GitHub e proteção da main

- A conta NexLabsTech foi verificada e teve acesso admin confirmado.
- Actions permanece habilitado; allowed_actions=local_only e sha_pinning_required=true.
- Workflow token: default_workflow_permissions=read; can_approve_pull_request_reviews=false.
- A workflow atual não usa actions externas; roda em ubuntu-latest por até 5 minutos, valida apenas o repositório público e não usa cache, artefatos, secrets ou serviço pago.
- Ruleset ativo: ID 28097099, NDS-main-governance, source NexLabsTech/docs-studio, target branch, enforcement active, condição refs/heads/main.
- Read-back do ruleset: bypass_actors=[]; current_user_can_bypass=never. Regras ativas: impedir deleção e force-push; histórico linear; PR obrigatório; threads resolvidas; merge squash; zero aprovações GitHub configuradas pela receita; check docs-validation requerido com política strict.
- Leitura efetiva em GET /repos/NexLabsTech/docs-studio/rules/branches/main confirmou as cinco regras derivadas do ruleset 28097099.
- Leitura da proteção legada em GET /branches/main/protection retornou HTTP 404 Branch not protected. A proteção efetiva da main é o ruleset ativo acima.
- Leitura prévia de rulesets, com includes_parents=true, retornou [] antes da criação; nenhuma regra existente foi substituída nem duplicada.
- Custo: [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners) e [billing de Actions](https://docs.github.com/en/actions/concepts/billing-and-usage) documentam runners padrão gratuitos em repositórios públicos; [rulesets disponíveis](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets) documenta rulesets públicos no plano gratuito. O repositório foi verificado como público. Nenhum runner maior, cache, artefato, assinatura ou plano pago foi habilitado.

## Validações e comandos executados

Os comandos locais foram executados no checkout limpo do SHA solicitado e repetidos após as alterações documentais:

| Comando | Código | Resultado |
|---|---:|---|
| python --version | 0 | Python 3.12.10 |
| python scripts/validate_docs.py --self-test | 0 | 1 teste; OK |
| python scripts/validate_docs.py | 0 | docs-validation: PASS; 37 required paths; 0 errors |
| git diff --cached --check | 0 | Sem erros de whitespace no diff staged |
| Varredura determinística do diff staged para cabeçalhos de chave privada, tokens GitHub, chaves AWS AKIA e tokens OpenAI | 0 | common-secret-pattern-scan: PASS; nenhum conteúdo correspondente impresso |

Leituras e escritas administrativas, sem tokens/códigos no registro:

| Operação | Código | Resultado |
|---|---:|---|
| gh api user --jq .login | 0 | NexLabsTech |
| gh api repos/NexLabsTech/docs-studio --jq '{visibility,default_branch,permissions}' | 0 | public; main; admin=true/push=true |
| gh api repos/NexLabsTech/docs-studio/actions/permissions (PUT) | 0 | enabled=true; local_only; pinning SHA true |
| gh api repos/NexLabsTech/docs-studio/actions/permissions (GET) | 0 | Leitura de volta corresponde à policy aplicada |
| gh api repos/NexLabsTech/docs-studio/actions/permissions/workflow | 0 | Token read; sem aprovação de PR |
| gh api repos/NexLabsTech/docs-studio/rulesets?includes_parents=true (pré-criação) | 0 | [] |
| gh api .../rulesets (POST da receita versionada) | 0 | ID 28097099 |
| gh api .../rulesets/28097099 e .../rules/branches/main | 0 | Ativo; regras efetivas e sem bypass |
| gh api .../branches/main/protection | 1 | HTTP 404 para proteção legada; regra efetiva separada confirmada |
| gh run view 45671724553 --repo NexLabsTech/docs-studio | 0 | Documentation CI; pull_request; SHA e4ad...; docs-validation PASS |
| gh pr checks 10 --repo NexLabsTech/docs-studio | 0 | Socket Security checks e docs-validation passaram em e4ad... |

O resultado hosted anterior no SHA inicial teve startup_failure e jobs=[]; ele não contou como PASS e não aceitava retry. O run válido 45671724553 executou as etapas de checkout público por SHA, self-test negativo e validação do repositório, todas com sucesso. A atualização final deste bundle dispara outra verificação; usar a página de checks da PR para confirmar o resultado exato no HEAD que contém esta versão.

## Matriz de aceite do NDS-CORE-WO-001

| AC | Estado | Evidência / explicação |
|---|---|---|
| AC01 | PASS — candidato | Source Pack e documentação canônica versionados na branch; source-check.md, hashes acima e PR #10. Não integrado nem promovido. |
| AC02 | BLOCKED / fora do PF-01 | Inventário de Windows, hardware, RAM/disco e modelo/effort não executado. |
| AC03 | BLOCKED / fora do PF-01 | Elegibilidade/termos e smoke do Remotion não executados. |
| AC04 | BLOCKED / fora do PF-01 | Kokoro e Faster Whisper não foram instalados nem exercitados. |
| AC05 | BLOCKED / fora do PF-01 | FFmpeg, ffprobe e SQLite locais não foram qualificados. |
| AC06 | BLOCKED / fora do PF-01 | ImageGen não foi chamado; fallback local não foi qualificado. |
| AC07 | BLOCKED / fora do PF-01 | Nenhum benchmark local foi executado. |
| AC08 | BLOCKED para o WO completo; PASS para elegibilidade inicial da CI | Repositório público, runner padrão gratuito e permissões mínimas confirmados. Checklist completo de dependências/licenças permanece fora do PF-01. |
| AC09 | PASS no SHA e4ad...; confirmar novo HEAD | Diff limitado a documentação/evidência, commit na PR autorizada e CI genuína passou nesse SHA. Conferir a verificação dinâmica do HEAD final após este commit. |
| AC10 | PASS para este bundle candidato | Bundle e proposta de delta estão presentes; qualificação técnica e auditoria independente continuam pendentes. |

## Escopo, riscos e gates

- Arquivos alterados nesta etapa: docs/19-governance.md e os dois artefatos CD-02. Não há código de produto.
- O checkpoint canônico docs/12-checkpoint.md não foi promovido nem alterado; a proposta está separada.
- Achado **MEDIUM**: falta auditoria independente. Achado **MEDIUM**: bundle registra o run e read-back; a nova verificação no HEAD que contém esta versão deve ser consultada antes de auditoria final. Nenhum HIGH/CRITICAL foi identificado no escopo administrativo limitado; isso não equivale a auditoria de segurança.
- Rollback disponível: remover ruleset 28097099 se o read-back revelar incompatibilidade; restaurar Actions para allowed_actions=all e sha_pinning_required=false se a policy impedir execução necessária. Nenhuma dependência ou dado de produto mudou.
- Não há aprovação própria nem merge. Mesmo com zero aprovações GitHub no ruleset, a auditoria independente é gate obrigatório fora do mecanismo de reviews.
- Próximo gate: confirmar CI verde no HEAD final; então submeter o bundle ao auditor independente. PR #10 fica Draft e sem merge. CORE fase 1 permanece bloqueada.

## Delta proposto

Ver CD-02-checkpoint-delta.md. Não atualizar o checkpoint canônico antes da decisão do auditor.
