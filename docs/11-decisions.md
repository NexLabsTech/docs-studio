# Decisions Ledger / ADRs
States: APPROVED product direction (user approval 2026-11-25), PROPOSED implementation details requiring proof/ratification, BLOCKED unknown capability. No decision rewritten silently.
| ID | Status | Decision / rationale |
|---|---|---|
| D001 | APPROVED | Mega Engineering cinematic, en-US, US audience, original documentary. |
| D002 | APPROVED | YouTube long-form MVP complete; Instagram/TikTok vertical later; no auto publication. |
| D003 | APPROVED | Local Windows single user, monolith, React/TS + SQLite, Remotion, Kokoro, Faster Whisper, FFmpeg; no unnecessary SaaS/cloud. |
| D004 | APPROVED | Zero incremental paid subscriptions/API costs; use existing Codex plan, no billing fallback or bypass. |
| D005 | APPROVED | GPT-6 Luna preferred where available, Max preference subject to actual availability/consumption; minimize LLM work, do not assume Max saves tokens. |
| D006 | APPROVED | Cinematic Industrial palette, adaptive runtime default 8–12 min, factual hooks and creative variety; editorial targets experimental. |
| D007 | APPROVED | ImageGen prefer Codex if verified; manual import fallback; original/properly licensed audio; source and disclosure records. |
| D008 | APPROVED | Metadata supports future vertical without implementing it; human approval, manual upload. |
| D009 | PROPOSED | Exact compatible toolchain, SQLite adapter, schema versions, implementation layout, benchmark budgets; qualify in CORE. |
| D010 | PROPOSED | Pilot Kansai Airport, subject to source research. |
| D011 | PROPOSED | Git remote/visibility, CI entitlement and budget, local install paths; no remote specified at original approval. |
| D012 | PROPOSED | Optional OpenChatCut only if demonstrated incremental benefit without expense/complexity. |
| D013 | PROPOSED | Post-MVP official YouTube upload/publishing, owner approval required to change D002/D008; see #8 and docs/18. No live upload or OAuth setup authorized. |
| D014 | APPROVED (repository destination only) | Owner created NexLabsTech/docs-studio and requested organization there on 2026-11-25. Connector verified public main and admin/push permissions. CI entitlement and local paths in D011 remain unqualified. |
| D015 | PROPOSED | SemVer release plan, repository-wide software license selection pending owner; do not publish executable release before gates. |
| D016 | APPROVED | Public standard-runner documentary CI and active main ruleset #28097099, no bypass; solo owner zero required human GitHub approvals plus mandatory independent engineering audit. Verified on PF-01 head be0e922, CI 45674205312. Preserve stronger effective controls, including GitHub's extra approval for unattributed changes; docs/19. |
| D017 | APPROVED | Owner delegates remaining administrative GitHub setup to the first local Codex prompt: NDS-CORE-WO-001/PF-01 executes NDS-BOOTSTRAP-001/CD-02 on PR #10; preserve all gates, cost zero, no bypass, independent audit before merge. No product implementation or other WO starts. |
