# John Muschelli — personal website

A [Quarto](https://quarto.org) website. Pages are plain Markdown (`.qmd`);
lists of things are YAML in `data/`.

## Everyday edits

| To change…                | Edit                                   |
|---------------------------|----------------------------------------|
| Bio / contact             | `index.qmd`                            |
| About-page buttons        | `data/links.yml`                       |
| R packages                | `data/software.yml`                    |
| Talks                     | `data/talks.yml`, `data/seminars.yml` (newest at the top) |
| Teaching                  | `data/teaching.yml`                    |
| Shiny apps                | `data/apps.yml` (podcast, hackathons in `projects.qmd`) |
| Research page             | `research.qmd`, `data/research-papers.yml`, `data/research-repos.yml` |
| Publications list         | Replace `data/citations.bib` (Google Scholar export), then `Rscript _scripts/publications.R --lookup` |
| Publication links (DOIs)  | `data/publication-dois.yml` (cache; hand edits are kept) |
| Navbar, footer            | `_quarto.yml`                          |

Preview with `quarto preview` (or the **Render** button in RStudio/Positron);
build with `quarto render` → static site in `docs/`.

## Publishing (johnmuschelli.com)

GitHub Pages serves `docs/` on `master` (Settings → Pages → Deploy from a
branch → `master` / `/docs`). To publish: `quarto render`, then commit and push,
including `docs/`. `CNAME`, `.nojekyll`, the old talk-redirect pages and the old
asset folders are copied into `docs/` via `resources:` in `_quarto.yml`. If you
add a new top-level file (for example `NewTalk.html`), add it there too.

Sub-sites such as `johnmuschelli.com/intro_to_r/` are separate repos with their
own Pages and are unaffected.

## The design seed

The look of the site is **generated from a random string** in
`_design/seed.txt` (currently `6tp17xyyl4dhtp4l`).

`_design/decode-seed.R` hashes that string and reads every design choice off
the hash: base hue and colour harmony, light and dark palettes, a
heading/body/code font trio, corner radius, navbar style, link style, the
Quarto About-page template, and the hero artwork (an R-drawn SVG: a Gaussian
fan, density ridgelines, or a scatter field). It runs automatically before
every render, and writes:

- `styles/_generated-light.scss`, `styles/_generated-dark.scss`: colour/font tokens
- `_design/about.yml`: About-page template and links
- `images/hero.svg`, `images/hero-dark.svg`: hero artwork (light/dark palettes)
- `_design/BRIEF.md`: the decoded design in plain English

**Don't like it?** Put any new string in `_design/seed.txt` and re-render, e.g.
`Rscript -e 'cat(paste(sample(c(letters,0:9),16,TRUE),collapse=""))' > _design/seed.txt`.
**Like it but want to tweak?** Edit `styles/custom.scss` (how tokens are used)
or the option lists inside `decode-seed.R` (what the seed can pick from).

## Old site

The previous hand-written HTML/CSS + Jekyll site is in `_legacy/` (ignored by
Quarto). Old URLs `research.html` and `contact.html` redirect to the new pages.
`mooc-generator/` is published file by file so `google_token.rds` never is.
