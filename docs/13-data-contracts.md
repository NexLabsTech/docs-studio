# Data model / internal contracts
Draft implementation contracts for qualification and subsequent WOs; not code or committed schema. Use SQLite foreign keys, migrations, transactions, versioned manifests, prepared statements. IDs stable; timestamps UTC; media paths relative to configured root, validated. No credentials.
- Project(id, title, language=en-US, status, createdAt, revision, mediaRootRef, editorialBriefId)
- Claim(id, projectId, text, unit, sourceIds[], confidence/status, reviewedAt, uncertainty)
- Source(id, URL, publisher, publicationDate?, accessedAt, locator, evidenceSummary, rightsNotes)
- Asset(id, projectId, kind, relativePath, sha256, provenance, licenseId, generationPromptRef?, reconstruction, durationMs?, dimensions?)
- License(id, source, licenseName, termsURL, retrievedAt, permittedUse, attribution, verificationStatus)
- Scene(id, projectId, startFrame, durationFrames, narrativeRole, claimIds[], assetIds[], focalPoint normalized x/y, safeMargins, effectSpecs[], voiceSegmentIds[], shortCandidate tag optional)
- WordTiming(segmentId, word, startMs, endMs, confidence?, reviewStatus); canonical timeline conversion to frames, monotonic intervals
- Job(id, projectId, stage, state, inputHash, outputHash?, attempts, startedAt?, finishedAt?, errorCode?, logRef?, toolchainHash)
- Artifact(id, jobId, type, relativePath, sha256, size, verificationStatus)
- Review(projectId, revision, kind, status, notes, reviewer, timestamp)
- ExportManifest(schemaVersion, projectId, revision, video, srt, titleThumbnailPairs[3], description, chapters[], claims, credits, disclosure, QA, manualPublishOnly=true)

Contract rules: no overlapping primary scenes except explicit transitions; timebase fps=30 for MVP; positive frame duration; timestamps monotonic; IDs resolve; invalid or missing assets block render; missing rights/claims block release; generated images carry reconstruction metadata; no secrets; validate on ingress/egress. Scene geometry normalized to support future crops; no vertical exporter in MVP. Internal APIs (proposed): createProject, getProject, updateBrief, importAsset, enqueueStage, cancelJob, retryJob, preview, render, export, approveReview. Writes require revision check; operation errors typed (INVALID_INPUT, STALE, MISSING_ASSET, LICENSE_BLOCKED, QUOTA_BLOCKED, DISK_LOW, TOOL_UNAVAILABLE, CANCELED, FAILED). UI cannot bypass editorial approval.
