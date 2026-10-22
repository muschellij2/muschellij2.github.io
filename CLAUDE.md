# Notes for Claude

This is a Quarto website; see README.md for layout.

**Design is seed-driven.** Before making any visual/design change, read
`_design/BRIEF.md` (decoded from `_design/seed.txt`) and stay within it: use
its palette, fonts, radius, and motif via the SCSS variables (`$primary`,
`$accent`, `$surface`, `$muted`, `$border-radius`, font-family vars). Never
hard-code colours or fonts in pages or `styles/custom.scss`.

- Never hand-edit generated files: `styles/_generated-*.scss`,
  `_design/about.yml`, `_design/BRIEF.md`, `images/hero.svg`, `images/hero-dark.svg`.
- New design dimensions go in `_design/decode-seed.R` as another `pick()` from
  unused hash digits, so the seed stays the single source of truth.
- Content lists live in `data/*.yml`, rendered via `_templates/*.ejs`.
  EJS templates must not be indented (Pandoc treats indented HTML as code).
- Render with `quarto render`. If `quarto` isn't on PATH, use the RStudio copy:
  `/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto`.
- Output goes to `docs/` (GitHub Pages for johnmuschelli.com). New top-level
  files that must stay online need a `resources:` entry in `_quarto.yml`.
  Never add `mooc-generator/` as a whole folder: it holds an untracked
  `google_token.rds` credential.

## Status (2026-10-21)

Redesign is **live**: merged to `master`, GitHub Pages serves `master` `/docs`.
`ISBI_2017.zip` is no longer published (imaging_in_r stopped linking it).
Open items for John to decide:
- Tick "Enforce HTTPS" in Settings → Pages once GitHub issues the certificate.
- Dependabot flags jQuery 1.11.3 in `_legacy/jquery-1.11.3.min.js`; left on
  purpose (not served from `docs/`).
- AdSense auto-ads script was dropped (ads.txt kept); old UA analytics dropped
  (could add a GA4 ID).
- Five redirects (Emory_Talk, jobtalk, jnj_talk, jnj_talk2, Genentech_Talk)
  point at dead rawgit.com; could repoint to the RIP_SlideDeck_2013 repo.
- `eba_2025.html` talk not listed on Talks page: venue ("EBA") unknown.
- Penn 2017 / Rochester 2016 listed as invited seminars: unconfirmed.
