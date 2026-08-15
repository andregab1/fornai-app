# Fornai Checklist — Execution Plan

Status legend: `[x]` executed and validated; `[ ]` pending; `[!]` requires human review.

## Objective

Deliver a local-first Flutter checklist for the current Fortnite Sprite/Elemental collection, with stable catalog identifiers, non-destructive updates, accessible Brazilian Portuguese UI, reliable progress tracking, and portable JSON backups.

## Scope

Android and iOS Flutter client; versioned bundled catalog; local persistence; collection/dashboard; Elemental cards with variant subchecks; details; search and filters; bulk actions; reset confirmation; import/export; approved local image assets; unit/widget tests; Android build; iOS build documentation.

## Out of scope for MVP

Backend, Firebase, authentication/accounts, cloud sync, social/trading features, remote publishing, automatic scraping in the app, ads, analytics, store publication, and unapproved third-party image redistribution.

## Technical decisions proposed for approval

- Flutter + Dart with feature-first folders and thin repository boundaries.
- Riverpod for predictable state, derived filters/progress, dependency injection, and test overrides.
- Hive CE is the initial preference over Isar: simpler key/value persistence for a small progress map, straightforward non-destructive merging, pure-Dart-friendly tests, and lower schema/code-generation pressure. Reassess if query volume or structured local catalog editing becomes substantial. No dependency is added until approval.
- Immutable manual Dart models initially; introduce code generation only if its maintenance benefit is demonstrated.
- Bundled, versioned JSON is authoritative at runtime only after human approval of its records.
- Stable IDs are semantic lowercase ASCII identifiers controlled by this project, never array indices or localized names; variants use their own stable IDs.
- User progress is stored separately from catalog records as `variantId -> {collected, collectedAt}` so catalog replacement cannot erase checks.

## Proposed folder structure

```text
lib/
  app/
  core/errors/
  core/theme/
  features/catalog/data/
  features/catalog/domain/
  features/catalog/presentation/
  features/collection/data/
  features/collection/domain/
  features/collection/presentation/
  features/backup/
assets/data/
assets/images/elementals/
test/unit/
test/widget/
data/                       # research/audit, not runtime data
```

## Data model

`CatalogVersion(schemaVersion, catalogVersion, auditedAt)`; `Elemental(id, namePtBr, season, availability, primaryImageRef, variants)`; `Variant(id, elementalId, namePtBr, type, availability, imageRef)`; `ProgressEntry(variantId, collected, collectedAt)`; `ProgressBackup(schemaVersion, exportedAt, catalogVersion, entries)`.

Availability is an extensible value (`available`, `comingSoon`, `unavailable`, `unknown`) rather than a Boolean. Unknown catalog fields remain unknown and are never inferred into confirmed values.

## Persistence and migration

1. Load bundled catalog and validate schema/unique IDs/references.
2. Load progress independently.
3. Join by stable variant ID in memory.
4. On catalog upgrade, retain all known progress; expose orphaned progress for recovery/logging rather than deleting it.
5. Add new variants as unchecked; never reset matching IDs.
6. Maintain explicit storage and catalog schema versions with sequential, tested migrations.
7. Use atomic writes/transactions where the selected store supports them.

## Backup strategy

Export UTF-8 JSON containing format identifier, schema version, app/catalog version, timestamp, and progress entries only. Validate JSON type, required fields, supported versions, unique IDs, date format, and reasonable size before import. Parse and preview before writing; merge by default, with an explicit separately confirmed replace option. Keep current data unchanged on invalid/corrupt input and show a pt-BR error.

## Image strategy

The audit records candidate URLs only. No current image is approved for redistribution. After review, prefer an Epic-hosted source with explicit acceptable terms or user-supplied licensed assets. Download approved assets once, record provenance/terms/date/hash, optimize locally (WebP when appropriate), preserve alpha, prohibit hotlinks, and provide an original neutral placeholder. Detect duplicates by cryptographic hash only after downloads are authorized.

## Risks

- Catalog changes rapidly and the reference site's visible copy is stale relative to its JavaScript.
- Official posts confirm subsets but do not publish a machine-readable complete catalog.
- Localized names may differ from official pt-BR in-game strings.
- Image accessibility does not grant redistribution rights; crossovers add third-party IP risk.
- Hive/Isar package maintenance and platform compatibility must be rechecked immediately before dependency selection.
- Windows supports Android work but cannot build/sign iOS; macOS with Xcode is required.

## Milestones

### 1. Environment and bootstrap

- [x] Confirm Windows and absolute working/project paths.
- [x] Verify Flutter 3.44.2, Dart 3.12.2, Codex CLI 0.147.0, Git 2.53.0.windows.1.
- [x] Run `flutter doctor -v`; Android ready, Visual Studio missing only for Windows desktop.
- [x] Create the default Flutter project with `com.fornai`.
- [x] Initialize local Git.
- [x] Run `flutter pub get`, `flutter analyze`, and `flutter test` successfully.
- [x] Create and resolve persistent `fornai` launcher.

Completion: clean default project validates and launcher resolves from a newly constructed CMD environment.

### 2. Catalog audit

- [x] Inspect public HTML, robots.txt, 14 public JavaScript chunks, embedded structures, and image-path rules.
- [x] Compare with public Epic/Fortnite news, support, and Epic Communities update notes.
- [x] Record candidates, sources, URLs, conflicts, and uncertainties.
- [x] Re-audit immediately before implementation because the season/catalog is changing.

Completion: audit files are valid and no single unofficial source is promoted to definitive truth.

### 3. Human catalog and image review — STOP POINT

- [x] Owner approved implementation using the current 25/117 candidate snapshot, with uncertainty labels preserved.
- [!] Confirm official pt-BR display names for five uncertain items.
- [x] Third-party image sources rejected for the MVP; original local placeholders are used.

Completion: signed-off catalog records and asset policy. Do not proceed without approval.

### 4. Architecture and models

- [x] Added and documented Riverpod 3.4.2 and Hive CE Flutter 2.3.4 after approval.
- [x] Implemented immutable catalog/progress models, validation, repository contract, and explicit format errors.
- [x] Added versioned runtime catalog JSON without third-party image URLs.

Completion: unit-tested parsing, unique IDs, availability, and repository contracts.

### 5. Persistence

- [x] Implemented Hive CE progress repository after checking current pub.dev package status.
- [ ] Checks persist immediately; sequential migrations remain pending until a second storage schema exists.
- [x] Tested persistence repository behavior and preservation of orphaned/legacy progress.

Completion: persistence and non-destructive migration tests pass.

### 6. Interface and navigation

- [x] Built theme, responsive shell, dashboard, cards with subchecks, and detail bottom sheet.
- [x] Added accessible labels, high-contrast theme, native controls, tooltips, and 44px interaction rows.

Completion: widget tests and visual review at compact and large phone sizes.

### 7. Search, filters, and progress

- [x] Implemented accent-insensitive search, six filters, aggregate counts, bulk actions, and reset confirmation.

Completion: progress/filter/bulk-action tests pass, including zero and complete states.

### 8. Backup and restoration

- [ ] JSON copy export and validated merge import with corruption handling are complete; preview, explicit replace, and file sharing/saving remain pending.

Completion: round-trip, legacy-version, unknown-ID, duplicate-ID, invalid JSON, and atomic-failure tests pass.

### 9. Approved image incorporation — STOP POINT

- [x] Owner explicitly authorized the audited catalog images for personal, non-public use on 2026-08-15.
- [x] Downloaded 117 authorized PNG files, validated signatures, recorded SHA-256 provenance, found no duplicate hashes, and retained fallback placeholders.

Completion: every shipped asset has local file, provenance, and acceptable usage basis; no hotlinks.

### 10. Tests and builds

- [x] Ran formatting, `flutter analyze` with no issues, and five passing tests.
- [x] Built Android debug APK successfully.
- [x] Documented Windows limitation; iOS build remains for macOS/Xcode.

Completion: all gates pass with documented environment limitations.

### 11. Possible publication preparation — STOP POINT

- [ ] Legal/IP review, app naming/package IDs, privacy/store metadata, icons/screenshots, signing, and release checklist.

Completion: separate explicit publication approval; no upload occurs automatically.

## Validation commands

```powershell
dart format --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
flutter build apk
# iOS only on supported macOS/Xcode:
flutter build ios
```

## Open questions requiring the owner

1. Should the first approved snapshot target the currently observed 25/117 candidate catalog or wait for an in-game/official reconciliation?
2. Can you verify in-game whether John Wick, Ironmouse, Amendoim Torrado, Pollo, and Vini Jr. should be counted and provide their official pt-BR names?
3. Is the intended use private/personal prototype or eventual public app-store distribution?
4. Will you provide licensed images, or should a later phase pursue written permission/official media-kit assets and otherwise use placeholders?
5. On import, should the default be merge (recommended) with replace behind an extra confirmation?