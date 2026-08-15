# Initial catalog audit — 2026-08-15

## Executive result

- Candidate Elementals in the current public JavaScript bundle: **25**.
- Elementals directly confirmed by located Epic/Fortnite announcements or update notes: **20**.
- Elementals still requiring stronger item-specific confirmation: **5** — John Wick, Ironmouse, Amendoim Torrado, Pollo, and Vini Jr.
- Candidate trackable variant entries computed from the current bundle's availability sets: **117**.
- Conservatively confirmed variant entries: **84**; entries requiring item-specific reconciliation: **33**.
- The site's visible/SEO copy still reports **22 Elementals / 83 variants**, conflicting with its current bundle.
- “Coming soon” status is internally inconsistent for John Wick: stale copy calls it upcoming while the current code no longer places it in a coming-soon set.

These figures are an audit snapshot, not an approved runtime catalog.

## Sources consulted

1. `https://www.fortniteking.com/` — unofficial reference; raw HTML and 14 public Next.js chunks inspected.
2. `https://www.fortniteking.com/robots.txt` — allows `/` for the general user agent, disallows auth/admin paths, reserves AI training, and permits reference use; restricted paths were not accessed.
3. Epic/Fortnite: Runners launch article and v41.00 update notes.
4. Epic Communities v41.10 and v41.30 Battle Royale update notes.
5. Fortnite article “DC Sirens Bring the Heat” for Batman and standard special variants.
6. Epic Communities posts for Llama, Peely, Quack, Grim Holofoil, and Zero Point Holofoil/Cube.
7. Epic support article describing Sprites.
8. Search-only community/Fandom evidence used solely to flag uncertain items, never as definitive confirmation.

## Public data structure and requests

The page is Next.js. Catalog data is embedded in public JavaScript rather than loaded from a dedicated public catalog JSON endpoint. The audited chunk exposes:

- stable-looking uppercase keys and slugs;
- rarity and supported variant keys;
- localized labels/descriptions;
- availability sets for Holofoil, Cube, Gem, and Quack;
- image path construction: `/sprites/{spriteSlug}_{variantSlug}.png`;
- variant slugs: `basic`, `gold`, `candy`, `galaxy`, `holofoil`, `cube`, `quack`, `gem`.

The scripts also contain a public Supabase URL/key for optional site accounts, but no authentication or database endpoint was queried because it is unnecessary and outside this audit.

## Counts and quality checks

- Missing image URLs: **0 candidate URLs** (a deterministic URL can be constructed for every trackable entry).
- Proven accessible image files: **not exhaustively tested**; no bulk image requests were made.
- Duplicate image bytes: **not assessed**, because hashing would require downloading images.
- Duplicate Elemental names/IDs in the extracted list: **0**.
- Duplicate variant keys within an Elemental: **0**.
- Candidate “Em breve”: **1 disputed item (John Wick)** in stale copy; current code conflicts.
- Official image URLs found for individual transparent Sprite catalog art: **0**.
- Candidate image host for all entries: `www.fortniteking.com` (**unofficial**).

## Candidate Elementals

| ID | Display label (audit) | Status |
|---|---|---|
| water | Água | official confirmation located |
| earth | Terra | official confirmation located |
| fire | Fogo | official confirmation located |
| air | Ar | official confirmation located |
| fishy | Peixoto/Fishy | official confirmation located; pt-BR name needs in-game check |
| duck | Pato | official confirmation located |
| ghost | Fantasma | official confirmation located |
| demon | Demônio | official confirmation located |
| king | Rei | official confirmation located |
| aura | Aura | official confirmation located |
| striker | Atacante/Striker | official confirmation located; pt-BR name needs check |
| dream | Sonho/Dream | official confirmation located; pt-BR name needs check |
| punk | Punk | official confirmation located |
| boss | Chefe/Boss | official confirmation located; pt-BR name needs check |
| seven | Seven | official confirmation located |
| grim-reaper | Ceifador/Grim Reaper | official confirmation located |
| zero-point | Ponto Zero | official confirmation located |
| batman | Batman | official confirmation located |
| llama | Lootin' Llama | official confirmation located |
| peely | Peeky Peely | official confirmation located |
| john-wick | John Wick | not confirmed item-specifically in located official update text; current availability conflict |
| burnt-peanut | Amendoim Torrado | only unofficial/community evidence located |
| pollo | Pollo | only unofficial/community evidence located |
| vini-jr | Vini Jr. | only unofficial/community evidence located |
| ironmouse | Ironmouse | strong public/community evidence, but no item-specific Epic announcement located in this pass |

## Image origin inventory

Every entry in `catalog_review.json` records its exact candidate URL. All follow `https://www.fortniteking.com/sprites/...png`; the domain is unofficial. The site disclaimer itself says it is not affiliated with or approved by Epic. No license granting redistribution of these files was found.

## Incorporation recommendation

Do **not** ship the discovered images, hotlink them, or treat their public URLs as permission. For a private prototype, placeholders are still the safest default. For public distribution, obtain written permission or an applicable official Epic media-kit/license source and separately consider third-party crossover rights (Batman/DC, John Wick, Ironmouse, Vini Jr., etc.). Until then, incorporate no third-party Sprite art.

## Conflicts and uncertainties

- Visible 22/83 copy vs 25/117 computed current bundle.
- The bundle models up to 165 potential Elemental/variant combinations (20 eight-variant Elementals plus five normal-only), but only 117 are currently marked trackable by its own rules.
- John Wick status differs between stale copy and code.
- Availability changes are time/event driven and may change after this audit date.
- Some localized labels are fan translations and require in-game pt-BR verification.
- No official complete machine-readable catalog or official transparent-art CDN mapping was located.