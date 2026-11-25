# NDS-UI-WO-005 — Deliver minimal usable local studio
Status: BLOCKED / PLANNING DRAFT. Issue #5. Risk: STANDARD/ELEVATED. Depends on NDS-PIPE-WO-004 APPROVED + integrated checkpoint. Branch nds/ui-wo-005; correction NDS-UI-WO-005/CD-nn.
## OBJECTIVE
Deliver minimal usable local studio.
## CONTEXT
Read fresh Git, checkpoint, decisions, scope, DoD, architecture, requirements, relevant editorial/data/security/benchmark docs and previous Evidence Bundle. Recompile against actual base SHA; this draft is not authorization.
## SCOPE
Local React/TS views per docs/14, real project stages, source review, asset substitution, voice, preview, QA, render/export, storage and accessible errors. Bind loopback, Host/Origin/CSRF, no fake progress.
## OUT OF SCOPE
Anything beyond this WO, paid services, public upload, vertical editions, feature creep, destructive actions.
## FILES/SOURCES TO READ
README.md, AGENTS.md, docs/12, 11, 03, 10, 04, 02, 05, 06, 08, 13, 15, 16; preceding WO/evidence; inspect actual code before changes. Determine exact file list after fresh Source Check.
## REQUIREMENTS
R10,R12,R13,R15.
## ARCHITECTURE RULES
Preserve local modular monolith, approved boundaries, versioned manifests, secure paths, deterministic processing and zero extra cost. No silent decision changes.
## CONSTRAINTS
Context Lock, scoped changes, official dependencies, no secret/media leaks, CPU fallback where relevant, no paid CI, no premature checkpoint promotion.
## ACCEPTANCE CRITERIA
AC01 previous gate approved and fresh lock; AC02 scoped functionality proven; AC03 requirements traced to concrete tests; AC04 failure/recovery/security paths tested; AC05 performance/licensing/cost evidence relevant to scope; AC06 reproducible evidence and clean PR with no unresolved HIGH/CRITICAL. Refine concrete thresholds and subcriteria after prior qualification without weakening approved DoD.
## TESTS
E2E project-to-export with synthetic fixture, revision conflict, retry/cancel, security checks, keyboard/focus, lint/typecheck/build and actual Windows run.
Run relevant unit/lint/typecheck/build/integration gates, record exact commands and results.
## DELIVERABLES
Local UI and evidence; no upload button, login or social screens. Commit, push, PR, CI/evidence if qualified, proposed Checkpoint Delta.
## REVIEW FORMAT
pt-BR, base/head, lock, changed files, AC matrix, exact tests, risks, licenses/cost, benchmark and proposed verdict.
## STOP CONDITION
Stop on STALE/BLOCKED or at evidence submission; correction stays in this WO/PR. No next WO or merge/checkpoint promotion without independent APPROVED.
