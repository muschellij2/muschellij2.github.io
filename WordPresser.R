rm(list=ls())
library(knitr)
wp = TRUE
publish = TRUE


# knit2wp2 = function (input, title = "A post from knitr", ..., shortcode = FALSE, 
#                      encoding = getOption("encoding"), publish = TRUE) 
# {
#   out = knit(input, encoding = encoding)
#   on.exit(unlink(out))
#   con = file(out, encoding = encoding)
#   on.exit(close(con), add = TRUE)
#   content = knitr:::native_encode(readLines(con, warn = FALSE))
#   content = paste(content, collapse = "\n")
#   content = markdown::markdownToHTML(text = content, fragment.only = TRUE)
#   shortcode = rep(shortcode, length.out = 2L)
#   if (shortcode[1]) {
#     content = gsub("<pre><code class=\"([[:alpha:]]+)\">(.+?)</code></pre>", 
#                    "[sourcecode language=\"\\1\"]\\2[/sourcecode]", 
#                    content)
#   }
#   content = gsub("<pre><code( class=\"no-highlight\"|)>(.+?)</code></pre>", 
#                  if (shortcode[2]) 
#                    "[sourcecode]\\2[/sourcecode]"
#                  else "<pre>\\2</pre>", content)
#   content = knitr:::native_encode(content, "UTF-8")
#   title = knitr:::native_encode(title, "UTF-8")
#   return(list(content = content, title=title))
# }

#### set up new post
wpfol <- "WordPress_Hopstat"
wpdir <- file.path("~/Dropbox/Public", wpfol)
wpdir <- path.expand(wpdir)
# mytitle <- folname <- "A full structural MRI processing pipeline in R"
mytitle <- folname <- "R CMD INSTALL with symlink to R"
categories = c("bmorebiostats")
# categories = "rbloggers"
# categories = c("rbloggers", "bmorebiostats")
#"bmorebiostats"

# folname <- "Converting LaTeX to MS Word"

folname = gsub(" ", "_", folname)
folname = gsub(",", "_", folname)
folname = gsub("'", "_", folname)
folname = gsub(":", "_", folname)
folname = gsub(";", "_", folname)


fol = file.path(wpdir, folname)
rmdname <- file.path(wpdir, folname,  paste0(folname, ".Rmd"))

if (!file.exists(fol)) {
  dir.create(fol)
}
if (!file.exists(rmdname)) {
  file.create(rmdname)
  addtxt = paste0("---\n", 
                  paste0('title: "', mytitle, '"\n'), 
                  'author: "John Muschelli"\n', 
                  "date: '`r Sys.Date()`'\n", "output: html_document\n", "---\n")
  addtxt = paste0(addtxt, 
                  "```{r label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE}", 
                  "\n", "library(knitr)\n", "opts_chunk$set(echo=TRUE, ", 
                  "prompt=FALSE, message=FALSE, warning=FALSE, ", 
                  'comment="", ', "results='hide')\n", "```")
  cat(addtxt, file = rmdname)
}
system(sprintf("open %s", shQuote(rmdname)))
setwd(file.path(wpdir, folname))


######### Send it to the Website

if (wp) {
#   if (!require('RWordPress')) 
#     install.packages('RWordPress', 
#                      repos = 'http://www.omegahat.org/R', 
#                      type = 'source')
#   library(RWordPress)
  pwd = 'hopkinsstat'
  stopifnot(pwd != 'PWD')
  options(WordpressLogin = c(strictlystat = pwd))
  uname <- names(getOption("WordpressLogin"))
  
  options( WordpressURL = 'https://hopstat.wordpress.com/xmlrpc.php')
  
  ### change this for the new folder
  stopifnot(file.exists(rmdname))
  opts_knit$set(base.dir = file.path(wpdir, folname))
  #     opts_knit$set(
  #       base.url = paste0(
  #         'https://dl.dropboxusercontent.com/u/600586/', wpfol, '/'),
  #                   base.dir = wpdir)
  opts_knit$set(upload.fun = function(file) {
    print("Hey")
    imgur_upload(file, key = "9f3460e67f308f6")
  })
  
  opts_knit$set(upload.fun = imgur_upload, 
                base.url = NULL) # upload all images to imgur.com
  #   input = rmdname
  #   title = mytitle
  #   shortcode= TRUE
  #   encoding = getOption("encoding")
  #   debug({
  knit2wp(rmdname, 
          shortcode = TRUE,
          action = "newPost",
          title = mytitle, 
          categories = categories, 
          publish=publish)
  #     })
  #   x = knit2wp2(input = rmdname, 
  #           title = "Using Tables for Statistics on Large Vectors", categories = categories, 
  #           shortcode=c(TRUE, TRUE), 
  #           publish=publish)
  # # 
  #   x$content = gsub("&gt;", ">", x$content, fixed=TRUE)
  #   x$content = gsub("&lt;", "<", x$content, fixed=TRUE)
  #   x$content = gsub("&quot;", '"', x$content, fixed=TRUE)
  #   x$content = gsub("&#39;", "'", x$content, fixed=TRUE)
  #   x$content = gsub("&rsquo;", "'", x$content, fixed=TRUE)
  #   x$content = gsub("&rdquo;", '"', x$content, fixed=TRUE)
  #   x$content = gsub("&ldquo;", '"', x$content, fixed=TRUE)
  #   x$content = gsub("&amp;", '"', x$content, fixed=TRUE)
  # 
  #   x$content = gsub("\\(", "ZZZZZZZ", x$content, fixed=TRUE)
  #   x$content = gsub("\\)", "$", x$content, fixed=TRUE)
  #   x$content = gsub("ZZZZZZZ", "$latex ", 
  #                    x$content, fixed=FALSE)
  # 
  #   writeLines(text =x$content, con=gsub("[.]Rmd$", "_text.html", rmdname))
  purl(rmdname)
}
