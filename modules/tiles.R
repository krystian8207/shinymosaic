tiles_page <- page(
  "tiles",
  "Choose collection", 
  segment(
    div(
      class = "ui two column very relaxed grid", 
      div(class = "column", multiple_checkbox("set", "Select from predefined sets of tiles", 
                                           choices = c("dogs", "cats", "cars"))),
      div(class = "column", textInput("tags", "Search for tags"), actionButton("confirm_tags", "Confirm"))
    ),
    div(class = "ui vertical divider", "or")
  ), 
  list(id = "home", title = "Home", icon = "angle double left"),
  list(id = "picture", title =  "Choose picture", icon = "angle double right")
)



tiles_callback <- function(input, output, session, tiles_path) {

  observeEvent(input$set, {
    tiles_path(input$set)
  })
  
  observeEvent(input$confirm_tags, {
    tiles_path(input$tags)
    prepare_tiles(tiles_path())
  })
  
}

prepare_tiles <- function(tiles_path) {
  target_path <- "tile"
  unlink(target_path, recursive = TRUE)
  dir.create(target_path)
  size <- c(30, 20)
  
  message("downloading data")
  for (tile_path in tiles_path) {
    api_url <- httr::GET(glue::glue("https://api.creativecommons.engineering/v1/images/?q={tile_path}&type=jpg&size=small&page_size=500&page=1"))
    images_meta <- content(api_url)$results
    urls <- images_meta %>% purrr::map_chr("url") %>% unique()
    unlink(tile_path, recursive = TRUE)
    dir.create(tile_path)
    download.file(urls, destfile = file.path(tile_path, basename(urls)))
  }
  
  message("resizing images")
  for (tile_path in tiles_path) {
    for (img in list.files(tile_path, pattern = "jpg")) {
      print(img)
      im <- load.image(file = file.path(tile_path, img))
      if (dim(im)[4] != 3) {
        next
      }
      thmb <- resize(im, size[1], size[2])
      imager::save.image(thmb, file = file.path(target_path, img))
    }
  }
  message("done")
}
