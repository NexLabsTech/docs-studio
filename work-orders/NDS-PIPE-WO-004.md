# NDS-PIPE-WO-004 — Build persistent orchestration and local contracts
Status: BLOCKED / PLANNING DRAFT. Issue #4. Risk: ELEVATED. Depends on NDS-MOTION-WO-003 APPROVED + integrated checkpoint. Branch nds/pipe-wo-004; correction NDS-PIPE-WO-004/CD-nn.
## OBJECTIVE
Build persistent orchestration and local contracts.
## CONTEXT
Read fresh Git, checkpoint, decisions, scope, DoD, architecture, requirements, relevant editorial/data/security/benchmark docs and previous Evidence Bundle. Recompile against actual base SHA; this draft is not authorization.
## SCOPE
SQLite migrations/transactions, manifests, claims/source/rights, stage DAG, cache hashes, atomic artifacts, retry/cancel/recovery, manual export manifest, approval boundary.
## OUT OF SCOPE
Anything beyond this WO, paid services, public upload, vertical editions, feature creep, destructive actions.
## FILES/SOURCES TO READ
README.md, AGENTS.md, docs/12, 11, 03, 10, 04, 02, 05, 06, 08, 13, 15, 16; preceding WO/evidence; inspect actual code before changes. Determine exact file list after fresh Source Check.
## REQUIREMENTS
R02,R03,R04,R09,R12,R14,R15,R16,R18.
## ARCHITECTURE RULES
Preserve local modular monolith, approved boundaries, versioned manifests, secure paths, deterministic processing and zero extra cost. No silent decision changes.
## CONSTRAINTS
Context Lock, scoped changes, official dependencies, no secret/media leaks, CPU fallback where relevant, no paid CI, no premature checkpoint promotion.
## ACCEPTANCE CRITERIA
AC01 previous gate approved and fresh lock; AC02 scoped functionality proven; AC03 requirements traced to concrete tests; AC04 failure/recovery/security paths tested; AC05 performance/licensing/cost evidence relevant to scope; AC06 reproducible evidence and clean PR with no unresolved HIGH/CRITICAL. Refine concrete thresholds and subcriteria after prior qualification without weakening approved DoD.
## TESTS
State transitions, stale invalidation, duplicate prevention, disk-full, drive disconnect, restart, cancellation, path safety, SQLite backup/restore and integration through actual adapters.
Run relevant unit/lint/typecheck/build/integration gates, record exact commands and results.
## DELIVERABLES
Versioned schemas, pipeline and tests, no public API or social uploads. Commit, push, PR, CI/evidence if qualified, proposed Checkpoint Delta.
## REVIEW FORMAT
pt-BR, base/head, lock, changed files, AC matrix, exact tests, risks, licenses/cost, benchmark and proposed verdict.
## STOP CONDITION
Stop on STALE/BLOCKED or at evidence submission; correction stays in this WO/PR. No next WO or merge/checkpoint promotion without independent APPROVED.
