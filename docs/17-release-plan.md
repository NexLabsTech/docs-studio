# Release plan (proposed; no releases published)
SemVer, immutable tags only on audited integrated commits. Do not label planning as functioning software.
| Candidate version | Gate | Content |
|---|---|---|
| v0.1.0 | CORE approved | Qualified development baseline, not application |
| v0.2.0 | MEDIA approved | Media foundation |
| v0.3.0 | MOTION approved | Cinematic renderer |
| v0.4.0 | PIPE approved | Persistent pipeline |
| v0.5.0 | UI approved | Local studio preview |
| v1.0.0-rc.1 | PILOT approved | Full pilot and second distinct fixture |
| v1.0.0 | QA approved + D01–D11 satisfied | Validated Windows MVP |
| v1.x | Separate owner approval | Optional upload and/or vertical exports; sequence TBD |

Release checklist: clean main, SHA and audited PR, changelog, tests and CI evidence, dependency lock/licenses, local install/rollback, no known HIGH/CRITICAL, SHA256 of distributable if applicable, checkpoint and limitations. Do not expose private footage, models, credentials or licensed media in release assets. No binary until actual tested packaging. No release tag or GitHub release created at bootstrap. Repository-wide licensing requires owner decision.
