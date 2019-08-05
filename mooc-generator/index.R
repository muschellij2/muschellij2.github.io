## ------------------------------------------------------------------------
if (!requireNamespace("didactr", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  remotes::install_github("muschellij2/didactr")
}


## ----read_token, eval = TRUE, message=FALSE, echo = FALSE----------------
library(didactr)
check_didactr_auth()

## ----token---------------------------------------------------------------
token$credentials$scope


## ----checking------------------------------------------------------------
check_didactr_auth()


## ----get_drive, eval = FALSE---------------------------------------------
res = googledrive::drive_find("Leanpub", type = "presentation")
res


## ----slide_df------------------------------------------------------------
slides = gs_slide_df(res$id[1])
slides
head(slides$png_url, 2)


## ----slide_notes---------------------------------------------------------
notes = notes_from_slide(res$id[1])
head(notes, 3)


if (!ari::have_ffmpeg_exec()) {
  stop("You need ffmpeg to create a video!")
}
video = gs_ari(res$id[1], output = "example_video.mp4")

uploaded = tuber::upload_video(file = "example_video.mp4", status = list(privacyStatus = "unlisted"))

