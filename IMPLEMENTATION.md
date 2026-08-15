# Fornai Checklist — Implementation Requirements

## Product objective

Build an Android and iOS Flutter mobile application that acts as a collector checklist for the Elementals, also called Sprites, from the current Fortnite season. It must show the complete currently available collection, including every confirmed Elemental and confirmed variant.

Each Elemental must have a permanent identifier, name, primary image, season, availability, variant list, and collected-variant progress. Each variant must have a permanent identifier, name, type/category, image, availability, collected state, and an optional date on which it was checked.

A number reported by only one unofficial source must never be treated as confirmed. The initial estimate of approximately 22 Elementals and 83 variants must be audited and is not definitive.

## User experience

Version 1 must include:

- Home screen with overall collection progress.
- “X de Y variantes” count, completion percentage, and visual progress bar.
- Card catalog showing each Elemental image and name.
- Main card showing collected variant count.
- Detail screen or panel when a card is tapped.
- Individual subchecks for every variant on the main Elemental card; do not create a completely independent home card per variant.
- Search by name.
- Filters: todos, completos, incompletos, não iniciados, disponíveis, em breve.
- Mark-all and unmark-all actions per Elemental.
- Confirmation before resetting the entire collection.
- “Em breve” state for announced but unavailable content.
- Offline operation.
- Accessible, responsive dark game-inspired theme without directly copying Fortnite's official interface.
- Adequate contrast and touch targets across different phone sizes.

## Variants

The model must support Normal, Dourado, Gelatinoso, Galáctico, other confirmed variants, and future variants without destructive migration. The primary Elemental card contains variant subchecks.

## Persistence, catalog updates, and backup

Version 1 is local and offline. Plan an appropriate Flutter local database, explicitly comparing Isar and Hive and justifying the initial choice. Checks persist immediately and survive application closure and updates. Use a versioned catalog and stable identifiers. Catalog updates must merge non-destructively so new Elementals/variants do not erase existing progress.

Provide JSON export/import and restoration. Validate backup schema and version; handle invalid or corrupt backups safely. Backups primarily contain progress and do not duplicate images. Plan Riverpod unless a better technical justification is documented.

## Catalog source and audit rules

Use https://www.fortniteking.com/ as an initial non-official reference only. It is neither definitive nor automatic permission to reuse content. Also research public official Epic Games sources and official CDNs when available.

Before UI implementation:

1. Access the reference page.
2. Inspect public HTML.
3. Inspect public JavaScript loaded by the page.
4. Inspect public requests used to load the catalog.
5. Identify public JSON, endpoints, or data structures containing names, identifiers, variants, availability, and image URLs.
6. Do not bypass authentication, CAPTCHA, blocks, paywalls, or protections.
7. Respect robots.txt, terms, and technical limits.
8. Compare against official public sources when possible.
9. Never invent missing data.
10. Record conflicts and uncertainty in `data/catalog_review.json` and `data/catalog_review.md`.

## Images and intellectual property

During planning, do not bulk-download or permanently incorporate images. Discover URLs, domains, the most official origin available, applicable terms, and separate confirmed from doubtful assets. After future approval, download only acceptable images, prefer Epic sources, store approved files in `assets/images/elementals/`, use stable lowercase names without spaces, consider WebP, preserve transparency and material visual quality, generate local placeholders when necessary, and record origin and license/conditions.

Never hotlink final assets, remove watermarks, copy ads/site logos/interface, obtain private signed URLs, or bypass expiry. Fortnite names, characters, images, and marks belong to Epic Games. Personal use, prototypes, and public distribution have different risk. Public accessibility is not redistribution permission. If permission is unclear, stop and identify assets requiring manual supply or authorization.

## Proposed architecture constraints

Use Flutter for Android/iOS, Riverpod for state, Hive or Isar for storage, a versioned JSON base catalog, repository boundaries between data and UI, immutable models, local images, backup import/export, unit tests, widget tests, and explicit error handling. Allow a future remote catalog update without requiring a backend in the MVP. Do not add Firebase, authentication, accounts, or a backend in version 1.

## Future quality gates

Plan and run, when appropriate: `dart format`, `flutter analyze` without errors, `flutter test`, progress-count tests, filter tests, persistence tests, export/import tests, catalog-update preservation tests, invalid-backup tests, visual checks at two screen sizes, Android build, and iOS build only in a supported macOS/Xcode environment. Document that Windows cannot produce an iOS build.

## Current phase boundary

This phase is environment setup, default Flutter bootstrap, local Git initialization, launcher setup, public catalog audit, and planning only. Do not implement final UI/features, add production dependencies, bulk-download/incorporate images, create backend/authentication, publish, create remote repositories, push commits, or continue beyond planning without human approval.