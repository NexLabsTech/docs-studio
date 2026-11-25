# NDS-MEDIA-WO-002 — Implement local media adapters and fixtures only
Status: BLOCKED / PLANNING DRAFT. Issue #2. Risk: STANDARD/ELEVATED. Depends on NDS-CORE-WO-001 APPROVED + integrated checkpoint. Branch nds/media-wo-002; correction NDS-MEDIA-WO-002/CD-nn.
## OBJECTIVE
Implement local media adapters and fixtures only.
## CONTEXT
Read fresh Git, checkpoint, decisions, scope, DoD, architecture, requirements, relevant editorial/data/security/benchmark docs and previous Evidence Bundle. Recompile against actual base SHA; this draft is not authorization.
## SCOPE
Validated image import/provider boundary; Kokoro en-US; Whisper alignment; FFmpeg audio mix/probe; provenance/rights and disk validation.
## OUT OF SCOPE
Anything beyond this WO, paid services, public upload, vertical editions, feature creep, destructive actions.
## FILES/SOURCES TO READ
README.md, AGENTS.md, docs/12, 11, 03, 10, 04, 02, 05, 06, 08, 13, 15, 16; preceding WO/evidence; inspect actual code before changes. Determine exact file list after fresh Source Check.
## REQUIREMENTS
R05,R06,R08,R12,R15.
## ARCHITECTURE RULES
Preserve local modular monolith, approved boundaries, versioned manifests, secure paths, deterministic processing and zero extra cost. No silent decision changes.
## CONSTRAINTS
Context Lock, scoped changes, official dependencies, no secret/media leaks, CPU fallback where relevant, no paid CI, no premature checkpoint promotion.
## ACCEPTANCE CRITERIA
AC01 previous gate approved and fresh lock; AC02 scoped functionality proven; AC03 requirements traced to concrete tests; AC04 failure/recovery/security paths tested; AC05 performance/licensing/cost evidence relevant to scope; AC06 reproducible evidence and clean PR with no unresolved HIGH/CRITICAL. Refine concrete thresholds and subcriteria after prior qualification without weakening approved DoD.
## TESTS
Real fixture TTS and CPU alignment; monotonic word times; ffprobe; path traversal and invalid files; missing model/quota/disk/error handling; license records; deterministic original SFX and mixing tests; no paid or unverified API.
Run relevant unit/lint/typecheck/build/integration gates, record exact commands and results.
## DELIVERABLES
Media contracts, tests and measured performance; no UI or full pipeline. Commit, push, PR, CI/evidence if qualified, proposed Checkpoint Delta.
## REVIEW FORMAT
pt-BR, base/head, lock, changed files, AC matrix, exact tests, risks, licenses/cost, benchmark and proposed verdict.
## STOP CONDITION
Stop on STALE/BLOCKED or at evidence submission; correction stays in this WO/PR. No next WO or merge/checkpoint promotion without independent APPROVED.
