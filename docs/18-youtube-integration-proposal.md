# D013 — Optional YouTube publishing integration
Status PROPOSED/FUTURE, issue #8. Requires owner ratification after MVP. Existing D002/D008/R13/DoD remain authoritative. No code, credentials, project creation or live upload in current scope.
## Feasibility
Use official YouTube Data API v3 and installed-app OAuth 2.0, not browser automation. Official documentation reviewed 2026-11-25: default 100 videos.insert calls/day, 100 search.list calls/day, 10,000 shared units for other endpoints. Current docs state unverified projects are no longer automatically private-only; this reverses older 2020 rule. Recheck actual Google project quota, OAuth verification/consent/testing limits, channel permissions and current policies before implementation. No paid API or quota extension assumption.
- https://developers.google.com/youtube/data/guides/authentication
- https://developers.google.com/youtube/data/guides/uploading_a_video
- https://developers.google.com/youtube/data/reference/rest/v3/videos/insert
- https://developers.google.com/youtube/data/reference/rest/v3/videos
- https://developers.google.com/youtube/data/guides/quota_and_compliance_audits
- https://developers.google.com/youtube/data/revision_history
- https://developers.google.com/youtube/terms/developer-policies
## Candidate user flow
Approved immutable ExportManifest revision and SHA256 -> show destination channel/title/privacy/metadata/disclosure/rights and explicit authorization -> resumable private upload -> reconcile returned videoId and processing state -> thumbnail/captions as permitted -> explicit approval of final publication or future schedule. Require correct channel and privacy, never rely on defaults. Full unattended publishing is not approved and would need a separate policy/consent decision. Provide manual fallback.
## Security and reliability
ELEVATED / HIGH_ASSURANCE for privileged auth and irreversible public actions. Minimum scopes validated per operation, system-browser OAuth with PKCE/loopback and state where supported, Windows protected credential store, no refresh token in Git/SQLite/logs. Revoke/disconnect flow. Idempotent local job key per channel+revision+asset hash; persist resumable state securely, no duplicate uploads on ambiguous response; reconcile or stop. Handle 401/403/429, quota, expired authorization, network drop, processing failure, wrong channel, retries, cancellation, clock/timezone; no unbounded retry. Redact logs. Status must distinguish locally exported, uploaded private, processing, scheduled and public.
## Gates
Mocks for auth/error/privacy/retry/dedup, no real account in CI; verify scope and zero additional cost; explicit permission for one private live test and read-back; independently audit publication authorization and metadata/AI disclosure. Public posting must never be a side effect of render alone. No new Google Cloud account/project or secret until approved. Recheck captions, thumbnails, scheduling API scopes/eligibility and rules for each endpoint. 
