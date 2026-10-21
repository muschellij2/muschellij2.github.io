# Decode the design seed into the site's look.
#
# The string in _design/seed.txt is hashed and every design decision
# (palette, fonts, shape, layout, hero art) is read off the hash.
# Change the seed -> re-render -> a new, but internally consistent, design.
#
# Runs automatically as a Quarto pre-render step (see _quarto.yml), or by hand:
#   Rscript _design/decode-seed.R

seed <- trimws(readLines("_design/seed.txt", n = 1, warn = FALSE))

tmp <- tempfile()
writeLines(seed, tmp)
hash <- unname(tools::md5sum(tmp))
unlink(tmp)

# hex digit i of the hash as an integer 0-15
hx <- function(i) strtoi(substr(hash, i, i), 16L)
# pick from a list using two hash digits
pick <- function(x, i) x[[(hx(i) * 16 + hx(i + 1)) %% length(x) + 1]]

# ---- palette ---------------------------------------------------------------
hue        <- round((hx(1) * 16 + hx(2)) / 255 * 360)
harmony    <- pick(list(
  list(name = "analogous",     offset = 40),
  list(name = "split",         offset = 150),
  list(name = "complementary", offset = 180),
  list(name = "triadic",       offset = 120)
), 3)
accent_hue <- (hue + harmony$offset) %% 360
chroma     <- 45 + hx(5) * 3          # 45-90: muted to vivid

col <- function(h, c, l) hcl(h, c, l, fixup = TRUE)
light <- list(
  primary = col(hue, chroma, 40),
  accent  = col(accent_hue, chroma, 50),
  bg      = col(hue, 6, 98),
  surface = col(hue, 10, 94),
  fg      = col(hue, 15, 18),
  muted   = col(hue, 10, 42)
)
dark <- list(
  primary = col(hue, chroma * 0.8, 75),
  accent  = col(accent_hue, chroma * 0.8, 70),
  bg      = col(hue, 10, 10),
  surface = col(hue, 12, 15),
  fg      = col(hue, 6, 92),
  muted   = col(hue, 8, 68)
)

# ---- typography ------------------------------------------------------------
fonts <- pick(list(
  list(head = "Fraunces",            body = "Inter",            mono = "JetBrains Mono"),
  list(head = "Space Grotesk",       body = "IBM Plex Sans",    mono = "IBM Plex Mono"),
  list(head = "DM Serif Display",    body = "DM Sans",          mono = "DM Mono"),
  list(head = "Playfair Display",    body = "Source Sans 3",    mono = "Source Code Pro"),
  list(head = "Bricolage Grotesque", body = "Inter",            mono = "Fira Code"),
  list(head = "Instrument Serif",    body = "Instrument Sans",  mono = "JetBrains Mono"),
  list(head = "Syne",                body = "Manrope",          mono = "Space Mono"),
  list(head = "Libre Caslon Text",   body = "Work Sans",        mono = "Fira Code")
), 6)

# ---- shape & layout --------------------------------------------------------
radius     <- pick(c("0", "0.3rem", "0.7rem", "1.25rem"), 8)
about_tpl  <- pick(c("jolla", "trestles", "solana", "marquee", "broadside"), 10)
navbar     <- pick(c("solid", "glass"), 12)
motif      <- pick(c("gaussian-fan", "density-ridges", "scatter-field"), 14)
underline  <- pick(c("thick", "offset", "highlight"), 16)

# ---- hero art (SVG, drawn from the seed) ------------------------------------
W <- 1200; H <- 260
path_d <- function(x, y) {
  paste0("M", paste(sprintf("%.1f,%.1f", x, y), collapse = " L"))
}

# Drawn once per palette (same random draw) -> images/hero.svg, hero-dark.svg
hero_svg <- function(p, file) {
  set.seed(strtoi(substr(hash, 17, 23), 16L))
  ramp <- colorRampPalette(c(p$primary, p$accent))

  svg_body <- switch(motif,
    "gaussian-fan" = {
      sds <- seq(0.25, 6, length.out = 60)
      cols <- ramp(length(sds))
      xs <- seq(-4, 4, length.out = 300)
      vapply(seq_along(sds), function(i) {
        y <- dnorm(xs, 0, sds[i]) / dnorm(0, 0, sds[1])
        sprintf('<path d="%s" fill="none" stroke="%s" stroke-width="1.2" opacity="0.8"/>',
                path_d((xs + 4) / 8 * W, H - 10 - y * (H - 30)), cols[i])
      }, "")
    },
    "density-ridges" = {
      n <- 18
      cols <- ramp(n)
      xs <- seq(0, 1, length.out = 300)
      vapply(seq_len(n), function(i) {
        mu <- runif(3, 0.15, 0.85); s <- runif(3, 0.03, 0.12); w <- runif(3)
        y <- rowSums(sapply(1:3, function(k) w[k] * dnorm(xs, mu[k], s[k])))
        y <- y / max(y) * 70
        base <- 40 + i * (H - 50) / n
        d <- paste0(path_d(xs * W, base - y), sprintf(" L%.1f,%.1f L0,%.1f Z", W, base, base))
        sprintf('<path d="%s" fill="var(--hero-bg)" stroke="%s" stroke-width="1.4"/>', d, cols[i])
      }, "")
    },
    "scatter-field" = {
      n <- 700
      x <- rnorm(n); y <- 0.6 * x + rnorm(n, sd = 0.8)
      cols <- ramp(10)[cut(x, 10, labels = FALSE)]
      sprintf('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s" opacity="0.65"/>',
              (x - min(x)) / diff(range(x)) * W,
              H - (y - min(y)) / diff(range(y)) * (H - 20) - 10,
              runif(n, 1, 4), cols)
    }
  )
  writeLines(c(
    sprintf('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" preserveAspectRatio="xMidYMid slice" role="img" aria-label="Decorative statistical artwork">', W, H),
    sprintf('<style>:root{--hero-bg:%s}</style>', p$surface),
    svg_body, "</svg>"), file)
}
hero_svg(light, "images/hero.svg")
hero_svg(dark, "images/hero-dark.svg")

# ---- write SCSS -------------------------------------------------------------
gfont <- function(f) gsub(" ", "+", f)
font_url <- sprintf(
  "https://fonts.googleapis.com/css2?family=%s:wght@400;600;700&family=%s:wght@400;500;700&family=%s&display=swap",
  gfont(fonts$head), gfont(fonts$body), gfont(fonts$mono))

scss <- function(p, mode) c(
  sprintf("// GENERATED by _design/decode-seed.R from seed '%s' -- do not edit by hand", seed),
  "/*-- scss:defaults --*/",
  sprintf("@import url('%s');", font_url),
  sprintf("$primary: %s;", p$primary),
  sprintf("$secondary: %s;", p$muted),
  sprintf("$info: %s;", p$accent),
  sprintf("$accent: %s;", p$accent),
  sprintf("$body-bg: %s;", p$bg),
  sprintf("$body-color: %s;", p$fg),
  sprintf("$surface: %s;", p$surface),
  sprintf("$muted: %s;", p$muted),
  sprintf("$link-color: %s;", p$primary),
  sprintf("$navbar-bg: %s;", if (navbar == "solid") p$primary else p$bg),
  sprintf("$navbar-fg: %s;", if (navbar == "solid") (if (mode == "light") "#ffffff" else p$bg) else p$fg),
  sprintf("$navbar-hl: %s;", if (navbar == "solid") (if (mode == "light") "#ffffff" else p$bg) else p$primary),
  sprintf("$footer-bg: %s;", p$surface),
  sprintf("$font-family-sans-serif: '%s', system-ui, sans-serif;", fonts$body),
  sprintf("$headings-font-family: '%s', Georgia, serif;", fonts$head),
  sprintf("$font-family-monospace: '%s', ui-monospace, monospace;", fonts$mono),
  sprintf("$border-radius: %s;", radius),
  sprintf("$card-radius: %s;", radius),
  sprintf("$navbar-style: '%s';", navbar),
  sprintf("$link-style: '%s';", underline),
  sprintf("$theme-mode: '%s';", mode)
)
writeLines(scss(light, "light"), "styles/_generated-light.scss")
writeLines(scss(dark, "dark"), "styles/_generated-dark.scss")

writeLines(c(
  "# GENERATED by _design/decode-seed.R -- do not edit by hand",
  "about:",
  sprintf("  template: %s", about_tpl),
  "  image: images/headshot.jpg",
  "  image-shape: rounded",
  "  image-width: 16em",
  "  links:",
  paste0("    ", readLines("data/links.yml"))
), "_design/about.yml")

# ---- human/agent-readable brief --------------------------------------------
brief <- c(
  sprintf("# Design brief for seed `%s`", seed),
  "",
  "_Generated by `_design/decode-seed.R`. Do not edit; change `_design/seed.txt` instead._",
  "",
  sprintf("- **Hash:** `%s`", hash),
  sprintf("- **Base hue:** %d deg, **harmony:** %s (accent hue %d deg), **chroma:** %d",
          hue, harmony$name, accent_hue, chroma),
  sprintf("- **Light palette:** primary `%s`, accent `%s`, bg `%s`, text `%s`",
          light$primary, light$accent, light$bg, light$fg),
  sprintf("- **Dark palette:** primary `%s`, accent `%s`, bg `%s`, text `%s`",
          dark$primary, dark$accent, dark$bg, dark$fg),
  sprintf("- **Fonts:** headings *%s*, body *%s*, code *%s*", fonts$head, fonts$body, fonts$mono),
  sprintf("- **Corner radius:** `%s`", radius),
  sprintf("- **Navbar:** %s, **link style:** %s", navbar, underline),
  sprintf("- **About layout:** Quarto `%s` template", about_tpl),
  sprintf("- **Hero motif:** %s (drawn in R, `images/hero.svg` / `images/hero-dark.svg`)", motif)
)
writeLines(brief, "_design/BRIEF.md")
message(paste(brief, collapse = "\n"))
