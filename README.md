# NexLabs Documentary Studio (NDS)

> Local-first cinematic documentary production for YouTube.

[![Status](https://img.shields.io/badge/status-planning-40C5D5)](docs/12-checkpoint.md) [![Target](https://img.shields.io/badge/target-v1.0.0-E9A23B)](docs/17-release-plan.md) [![Platform](https://img.shields.io/badge/platform-Windows-142C3D)](docs/07-deployment.md)

NDS is a single-user Windows studio for original English-language Mega Engineering documentaries. Its target workflow is research → fact-check → script → storyboard → assets → voice → motion graphics → QA → export. It is not yet a functioning application.

## MVP
- American English, cinematic Industrial aesthetic, adaptive runtime (8–12 min preferred).
- Official Codex workflow, Remotion, Kokoro, Faster Whisper, FFmpeg, SQLite and a local React/TypeScript UI; actual availability and versions require qualification.
- 1080p/30fps MP4, SRT, three title/thumbnail candidates, description, chapters where applicable, fact/rights records.
- No additional subscriptions or paid API calls. Manual publishing after human review.
- Instagram/TikTok vertical editions deferred. YouTube OAuth/upload is a separate proposed post-MVP feature, not approved for implementation.

## Start here
Clone this repository into a new workspace. Read [checkpoint](docs/12-checkpoint.md), [decisions](docs/11-decisions.md), [scope](docs/03-scope.md), [DoD](docs/10-definition-of-done.md), [architecture](docs/04-architecture.md), [requirements](docs/02-requirements.md), then [AGENTS.md](AGENTS.md). Follow [PROMPT-CODEX.md](PROMPT-CODEX.md) for [NDS-CORE-WO-001](work-orders/NDS-CORE-WO-001.md) **only after bootstrap integration**. No application installation command exists yet.

## Documentation
| Source | Purpose |
|---|---|
| [Overview](docs/01-overview.md) | Product direction |
| [Requirements](docs/02-requirements.md) | R01–R19 |
| [Scope](docs/03-scope.md) | MVP boundaries |
| [Architecture](docs/04-architecture.md) | Local modular monolith |
| [Security](docs/05-security.md) | Threat model |
| [Test & benchmark](docs/06-test-benchmark.md) | Qualification and quality gates |
| [Deployment](docs/07-deployment.md) | Windows local |
| [Editorial bible](docs/08-editorial.md) | Narrative, sound and motion |
| [Backlog](docs/09-backlog.md) | Issues and dependencies |
| [Definition of Done](docs/10-definition-of-done.md) | Release gates |
| [Decisions](docs/11-decisions.md) | Decisions Ledger |
| [Checkpoint](docs/12-checkpoint.md) | Verified status |
| [Data contracts](docs/13-data-contracts.md) | Schemas, jobs, assets |
| [UI/UX](docs/14-ui-ux.md) | Local studio |
| [Recovery](docs/15-recovery.md) | Persistence and rollback |
| [Sources and licensing](docs/16-sources-licenses.md) | References and gates |
| [Release plan](docs/17-release-plan.md) | SemVer and release criteria |
| [YouTube integration proposal](docs/18-youtube-integration-proposal.md) | Future, gated |

Source hierarchy: checkpoint → decisions → scope → DoD → architecture → requirements → other relevant sources. Git/code/tests prevail over claims of implementation; approved decisions cannot be silently overwritten. Conflicts = STALE/BLOCKED.

## Engineering
Stable WO IDs, branch/PR, source fingerprints, evidence, independent audit, checkpoint delta and squash merge only after approval. See [roadmap](docs/09-backlog.md) and [templates](templates/). No secrets, private media, large models or caches in Git. The repository is public; no project-wide software license has been selected, and third-party licenses remain independent.
