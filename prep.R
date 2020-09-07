library(httr)
library(magrittr)
library(imager)
library(RsimMosaic)
urls <- character(0)
n_pages <- 2
for (page in 1:n_pages) {
  api_url <- httr::GET(glue::glue("https://api.creativecommons.engineering/v1/images/?q=tesla&type=jpg&size=small&page_size=500&page={page}"))
  images_meta <- content(api_url)$results
  urls <- c(urls, images_meta %>% purrr::map_chr("url"))
}
urls <- unique(urls)
orig_path <- "imgs"
unlink(orig_path, recursive = TRUE)
dir.create(orig_path)
download.file(urls, destfile = paste0("imgs/", basename(urls)))

target_path <- "tile"
unlink(target_path, recursive = TRUE)
dir.create(target_path)
size <- c(30, 20)

for (img in list.files(orig_path, pattern = "jpg")) {
  im <- load.image(file = file.path(orig_path, img))
  if (dim(im)[4] != 3) {
    next
  }
  thmb <- resize(im, size[1], size[2])
  imager::save.image(thmb, file = file.path(target_path, img))
}

orig_file_in <- "sudo.jpg"
im <- load.image(orig_file_in)
out_width <- 150
out_height <- floor(out_width / dim(im)[1] * dim(im)[2])
im_input <- resize(im, out_width, out_height)
fin_file <- paste0("fin", orig_file_in)
imager::save.image(im_input, file = fin_file)
orig_file_out <- file.path(getwd(), "verySmallMoon-2MASS-Mosaic.jpg")

composeMosaicFromImageRandom(fin_file, orig_file_out, target_path, removeTiles=FALSE)
