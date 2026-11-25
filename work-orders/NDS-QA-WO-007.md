# NDS-QA-WO-007 — Qualify full MVP and prepare v1.0.0
Status: BLOCKED / PLANNING DRAFT. Issue #7. Risk: ELEVATED. Depends on NDS-PILOT-WO-006 APPROVED + integrated checkpoint. Branch nds/qa-wo-007; correction NDS-QA-WO-007/CD-nn.
## OBJECTIVE
Qualify full MVP and prepare v1.0.0.
## CONTEXT
Read fresh Git, checkpoint, decisions, scope, DoD, architecture, requirements, relevant editorial/data/security/benchmark docs and previous Evidence Bundle. Recompile against actual base SHA; this draft is not authorization.
## SCOPE
Trace every requirement and DoD to proof; full regression, security, licenses, benchmark, local install/update/restart, backup/restore, documentation and release candidate.
## OUT OF SCOPE
Anything beyond this WO, paid services, public upload, vertical editions, feature creep, destructive actions.
## FILES/SOURCES TO READ
README.md, AGENTS.md, docs/12, 11, 03, 10, 04, 02, 05, 06, 08, 13, 15, 16; preceding WO/evidence; inspect actual code before changes. Determine exact file list after fresh Source Check.
## REQUIREMENTS
R01–R19 / D01–D11.
## ARCHITECTURE RULES
Preserve local modular monolith, approved boundaries, versioned manifests, secure paths, deterministic processing and zero extra cost. No silent decision changes.
## CONSTRAINTS
Context Lock, scoped changes, official dependencies, no secret/media leaks, CPU fallback where relevant, no paid CI, no premature checkpoint promotion.
## ACCEPTANCE CRITERIA
AC01 previous gate approved and fresh lock; AC02 scoped functionality proven; AC03 requirements traced to concrete tests; AC04 failure/recovery/security paths tested; AC05 performance/licensing/cost evidence relevant to scope; AC06 reproducible evidence and clean PR with no unresolved HIGH/CRITICAL. Refine concrete thresholds and subcriteria after prior qualification without weakening approved DoD.
## TESTS
Unit/integration/E2E, lint/typecheck/build, Windows native real media, approved benchmark budgets, free CI evidence, fresh deployment and recovery; no required test skipped.
Run relevant unit/lint/typecheck/build/integration gates, record exact commands and results.
## DELIVERABLES
Independent release audit, proposed checkpoint, verified packaging and SHA256, no tag until integrated. Commit, push, PR, CI/evidence if qualified, proposed Checkpoint Delta.
## REVIEW FORMAT
pt-BR, base/head, lock, changed files, AC matrix, exact tests, risks, licenses/cost, benchmark and proposed verdict.
## STOP CONDITION
Stop on STALE/BLOCKED or at evidence submission; correction stays in this WO/PR. No next WO or merge/checkpoint promotion without independent APPROVED.
