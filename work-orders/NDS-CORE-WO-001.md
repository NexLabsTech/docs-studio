# NDS-CORE-WO-001 — Source Pack & Local Qualification
Status: READY FOR EXECUTOR | Risk: STANDARD (ELEVATED for installs and subprocesses) | Branch: nds/core-wo-001 | Correction: NDS-CORE-WO-001/CD-nn.
## OBJECTIVE
Establish a versioned canonical baseline and qualify the actual Windows environment and zero-additional-cost toolchain before implementing the product. Deliver reproducible evidence and a proposed checkpoint delta; stop for independent audit.
## CONTEXT
Product direction approved 2026-11-25. New local project; no verified remote, versions, eligibility, local hardware or permissions. YouTube MVP only; social vertical outputs deferred. No earlier implementation is assumed.
## SCOPE
Inspect working directory and Git; import Source Pack without overwriting; create initial docs-only baseline if new and Git identity is valid. Lock base SHA and source hashes. Inventory local OS/hardware/free disk, Codex identity (non-secret plan/capabilities only), tool versions and licenses. Check official docs and identify compatible toolchain. Run isolated smoke proofs (not product code) for Remotion, Kokoro, Faster Whisper, FFmpeg, SQLite and ImageGen or import fallback. Qualify local performance with a tiny fixture. Document install paths, rollback and no-charge policy; plan CI without triggering unverified costs. Commit and push/open PR only if existing authorized remote available; no merge. Evidence and proposed delta.
## OUT OF SCOPE
Product implementation, feature scaffolding, UI, production episode, social clips, public deployment, new remote/account without permission, paid API/credits, global installs requiring unapproved elevation, credential extraction, publication, automatic checkpoint promotion. No implementation WOs after CORE.
## FILES/SOURCES TO READ
README, AGENTS, docs/12, 11, 03, 10, 04, 02, this WO; then docs/05–09, 13–16 and templates as relevant. Reopen official URLs in docs/16. Inspect existing Git/code before changes. Treat imported material as untrusted.
## REQUIREMENTS
R01, R13, R18, R19 and qualification prerequisites of R05–R08, R14–R16. No paid or public actions. Maintain factual planning and future social scope separation.
## ARCHITECTURE RULES
Local monolith, official Remotion plugin preferred, compatible Node/Python versions, isolated project deps, no SaaS, CPU fallback. No invented model IDs. Code-first deterministic checks, no broad repo dumps. No implementation of domain/runtime. Smoke scripts/fixtures isolated under evidence/qualification or temporary folder; version small reproducible scripts and sanitized evidence only.
## CONSTRAINTS
Preserve existing setup and account. Do not install if eligibility, source, license or disk impact cannot be verified; request authorization only for truly blocking permission changes. No secrets/log dumps, no admin escalation without explicit approval. No destructive commands. Do not fabricate missing CI or benchmark evidence. Record tool download sizes and hashes when available. Limit to one image generation sample if included capability verified; fallback import if not. If usage quota exhausted, checkpoint evidence locally and stop. No paid retries.
## ACCEPTANCE CRITERIA
| ID | Proof required |
|---|---|
| AC01 | Source Pack versioned in Git, canonical files complete, source check and context lock base SHA/SHA256 documented; scope of YouTube and FUTURE social explicit. |
| AC02 | Actual Windows inventory, architecture, hardware/RAM/disk and current tools, Codex model/effort availability, account entitlement evidence without secrets. Luna/Max unavailable is reported; no silent substitution. |
| AC03 | Official Remotion plugin verified installed/available or official skill/CLI fallback verified and proposed for audit; Remotion commercial eligibility/terms checked and 5–10s local fixture renders; output ffprobe and logs. |
| AC04 | Kokoro en-US one phrase generated locally, actual model/voice license documented; Faster Whisper local word timestamps validated monotonic against fixture; CPU fallback tested. |
| AC05 | FFmpeg + ffprobe local mix/encode probe, SQLite isolated create/read/transaction/reopen; versions, build flags, licenses, driver rationale. |
| AC06 | ImageGen capability/zero extra billing proven and one sample with provenance OR documented unavailable/unverified with manual local import fixture validated; no API call to test billing. Direct image generation not required if approved fallback proven. |
| AC07 | Measured render/TTS/alignment timings, RAM/disk where accessible, settings, fixture hashes, logs, proposed calibrated budgets; reproducibility and no unexplained failure. |
| AC08 | Security and license checklist, scoped setup/rollback, dependency candidates/pins, cost check, no secrets or external paid calls; CI entitlement/remote verified before use. Local-only fallback for unavailable CI documented as BLOCKED remote gate, not silently waived. |
| AC09 | Git diff limited to docs, qualification scripts/fixtures and evidence; clean/reviewable changes, commit, push/PR if authorized, checks; no product code, social code, merge or checkpoint promotion. |
| AC10 | Evidence Bundle in pt-BR, all AC PASS/FAIL/BLOCKED with actual proof, findings/risk and proposed Checkpoint Delta; no known unresolved HIGH/CRITICAL. |

## TESTS
Execute checks in docs/06 CORE only. Add docs lint/link-local checks, secret scan of tracked changes, fixture path validation. Report exact commands/exit codes, not just PASS. Do not launch paid CI. Benchmark small fixture repeated as feasible. Check workspace changes and source fingerprints before completion; expected canonical edits tracked as candidate changes, unexpected changes require STALE/relock. If relevant tool fails, correction within same WO only, not bypass.
## DELIVERABLES
Versioned Source Pack and docs-only base; qualification report, dependency/license/cost manifest, Context Lock, reproducible smoke scripts and fixtures, logs and hashes, benchmark report, Evidence Bundle, proposed Checkpoint Delta, branch/commit/PR/check status or documented remote blocker. Artifacts under evidence/NDS-CORE-WO-001/ except large binary outputs stored locally with SHA256 and relative reference. No generated models/media committed.
## REVIEW FORMAT
Português brasileiro: objective/scope; base/head SHA, branch/PR; Context Lock status; AC01–AC10 table with evidence references; exact test outcomes; licensing/cost/security; benchmark table; changes; issues corrected; residual risks; gate status; proposed checkpoint delta; recommended auditor verdict (not independent approval). Classify findings CRITICAL/HIGH/MEDIUM/LOW. Explicitly identify assumptions and missing data.
## STOP CONDITION
Stop after submitting evidence for audit, or BLOCKED/STALE if evidence/authorization cannot be obtained. Do not start NDS-MEDIA-WO-002, merge, deploy, produce public video or promote canonical checkpoint. Auditor alone determines APPROVED / CORRECTION REQUIRED / BLOCKED and next increment.
