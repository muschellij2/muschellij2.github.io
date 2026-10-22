# Build data/publications.yml (Publications page) from data/citations.bib.
#
#   Rscript _scripts/publications.R           # convert only, no network
#   Rscript _scripts/publications.R --lookup  # also look up missing DOIs
#
# Run after replacing data/citations.bib (e.g. a new Google Scholar export).
# DOIs are cached in data/publication-dois.yml (bib key -> DOI, or "" when no
# confident Crossref match); edit that file to fix or add a link by hand.
# A DOI is only accepted when the Crossref title is a near-exact match and
# Muschelli is in the Crossref author list.

suppressMessages({
  library(jsonlite)
  library(yaml)
})

bib_file   <- "data/citations.bib"
cache_file <- "data/publication-dois.yml"
out_file   <- "data/publications.yml"
lookup     <- "--lookup" %in% commandArgs(trailingOnly = TRUE)

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# ---- parse BibTeX with Pandoc (handles LaTeX escapes) -----------------------
pandoc <- Sys.getenv("QUARTO_PANDOC")
if (!nzchar(pandoc)) pandoc <- Sys.which("pandoc")
if (!nzchar(pandoc)) {
  arch <- if (R.version$arch == "aarch64") "aarch64" else "x86_64"
  pandoc <- file.path("/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools",
                      arch, "pandoc")
}
csl <- fromJSON(system2(pandoc, c(shQuote(bib_file), "-f", "bibtex", "-t", "csljson"),
                        stdout = TRUE), simplifyVector = FALSE)

# Google Scholar reuses keys for different papers (e.g. two MIMoSA papers):
# keep the first as-is and suffix repeats with _2, _3, ...
ids <- vapply(csl, `[[`, "", "id")
ids <- ave(ids, ids, FUN = function(x) if (length(x) > 1) c(x[1], paste0(x[1], "_", seq_along(x)[-1])) else x)
for (i in seq_along(csl)) csl[[i]]$id <- ids[i]

# Drop published corrections that Scholar exports as papers, e.g. "(vol 77, pg 131, 2020)"
csl <- Filter(function(e) !grepl("\\(vol [0-9]+, pg [0-9]+", e$title %||% ""), csl)

cache <- if (file.exists(cache_file)) read_yaml(cache_file) else list()
if (is.null(cache)) cache <- list()

# ---- helpers ----------------------------------------------------------------
norm <- function(x) gsub("[^a-z0-9]", "", tolower(x))

fmt_authors <- function(au) {
  # Scholar ends long author lists with "and others"
  etal <- length(au) > 0 && identical(au[[length(au)]]$literal %||% au[[length(au)]]$family, "others")
  if (etal) au <- au[-length(au)]
  nm <- vapply(au, function(a) {
    fam <- a$family %||% a$literal %||% ""
    fam <- sub("^Muschelli III$", "Muschelli", fam)  # match the name used on the site
    giv <- a$given %||% ""
    ini <- paste(substr(strsplit(giv, "[ .-]+")[[1]], 1, 1), collapse = "")
    trimws(paste(fam, ini))
  }, "")
  if (length(nm) > 10) {
    me <- grep("^Muschelli", nm)
    keep <- sort(unique(c(1:6, me, length(nm))))
    out <- character(0)
    for (i in seq_along(keep)) {
      if (i > 1 && keep[i] - keep[i - 1] > 1) out <- c(out, "…")
      out <- c(out, nm[keep[i]])
    }
    nm <- out
  }
  paste0(paste(nm, collapse = ", "), if (etal) ", et al." else "")
}

kind <- function(e) {
  if (grepl("^Abstract\\b", e$title %||% "")) return("Abstract")
  switch(e$type,
    "article-journal" = "Journal article",
    "paper-conference" = "Conference paper",
    "chapter" = "Book chapter",
    "thesis" = "Thesis",
    if (grepl("^Package", e$title %||% "")) "Software" else "Abstract")
}


crossref <- function(e) {
  q <- paste(e$title, e$author[[1]]$family %||% "")
  req <- httr2::request("https://api.crossref.org/works") |>
    httr2::req_url_query(rows = 5, select = "DOI,title,author,issued,type",
                         query.bibliographic = q) |>
    httr2::req_user_agent("johnmuschelli.com publications builder") |>
    httr2::req_retry(max_tries = 5, backoff = function(i) 2^i)
  res <- tryCatch(httr2::resp_body_json(httr2::req_perform(req)),
                  error = function(err) {
                    message("Crossref lookup failed for ", e$id, ": ", conditionMessage(err))
                    NULL
                  })
  if (is.null(res)) return(NULL)
  hits <- Filter(function(it) {
    ti <- it$title[[1]] %||% ""
    fams <- tolower(vapply(it$author %||% list(), function(a) a$family %||% "", ""))
    stringdist::stringsim(norm(ti), norm(e$title), method = "jw") >= 0.95 &&
      "muschelli" %in% fams
  }, res$message$items)
  if (!length(hits)) return(list(doi = "", year = NULL))
  # Prefer the published version over a bioRxiv/medRxiv preprint
  pub <- Filter(function(it) !identical(it$type, "posted-content"), hits)
  it <- if (length(pub)) pub[[1]] else hits[[1]]
  list(doi = tolower(it$DOI), year = it$issued$`date-parts`[[1]][[1]])
}

# ---- build entries ----------------------------------------------------------
items <- lapply(csl, function(e) {
  id <- e$id
  year <- e$issued$`date-parts`[[1]][[1]] %||% NA
  if (lookup && is.null(cache[[id]])) {
    hit <- crossref(e)
    if (!is.null(hit)) {
      cache[[id]] <<- hit$doi
      if (is.na(year) && !is.null(hit$year) && nzchar(hit$doi)) year <- hit$year
    }
    Sys.sleep(0.2)
  }
  doi <- cache[[id]] %||% ""
  venue <- e$`container-title` %||% e$publisher %||% ""
  if (e$type == "thesis") venue <- paste("PhD thesis,", e$publisher %||% "")
  type <- kind(e)
  list(
    title = e$title,
    description = fmt_authors(e$author %||% list()),
    venue = tools::toTitleCase(venue),
    year = if (is.na(year)) "Year unknown" else as.integer(year),
    type = type,
    categories = list(type),
    path = if (nzchar(doi)) paste0("https://doi.org/", doi) else
      paste0("https://scholar.google.com/scholar?q=", utils::URLencode(e$title, reserved = TRUE))
  )
})

yr <- vapply(items, function(x) if (is.numeric(x$year)) x$year else -1L, 0)  # undated last
items <- items[order(-yr, vapply(items, `[[`, "", "title"))]

writeLines(c("# Generated by _scripts/publications.R from data/citations.bib. Do not edit;",
             "# fix links in data/publication-dois.yml, then re-run the script.",
             as.yaml(items)), out_file)
cache <- cache[order(names(cache))]
writeLines(c("# bib key -> DOI (\"\" = no confident Crossref match). Hand edits are kept.",
             as.yaml(cache)), cache_file)

n_doi <- sum(vapply(items, function(x) grepl("doi.org", x$path), TRUE))
message(sprintf("%d publications, %d with DOIs -> %s", length(items), n_doi, out_file))
