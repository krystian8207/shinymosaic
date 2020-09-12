divider <- function(..., class = "") {
  div(class = glue::glue("ui {class} divider"), ...)
}
column <- function(..., class = "") {
  div(class = glue::glue("{class} column"), ...)
}
row <- function(..., class = "") {
  div(class = glue::glue("{class} row"), ...)
}

tiles_page <- page(
  "tiles",
  "Choose image collection",
  tagList(
    segment(
      class = "placeholder",
      div(
        class = "ui two column stackable center aligned grid",
        divider("OR", class = "vertical"),
        row(
          class = "middle aligned", 
          column(
            div(class = "ui icon header", icon("search"), span(class = "ui large text", "Select ready set")),
            div(
              class = "ui massive form",
              multiple_radio(
                "set", NULL, 
                choices = c("dogs", "cats", "cars"), position = "inline"
              )
            )
          ),
          column(
            div(class = "ui icon header", icon("world"), span(class = "ui large text", "Create your own")),
            div(
              class = "field",
              shiny.semantic::uiinput(
                class = "big right labeled left icon", icon("tags"), text_input(input_id = "tags", placeholder = "Enter tag"), 
                button("confirm_tags", "Confirm tag", class = "tag label")
              )
            )
          )
        )
      )
      #   div(
      #     class = "ui two column very relaxed grid", 
      #     div(class = "column", multiple_radio("set", "Select from predefined sets of tiles", 
      #                                          choices = c("dogs", "cats", "cars"))),
      #     div(class = "column", textInput("tags", "Search for tags"), actionButton("confirm_tags", "Confirm"))
      #   ),
      #   div(class = "ui vertical divider", "or")
    ),
    div(class = "ui large floating message", "Selected collection: cats", style = "text-align: center;")
  ),
  list(id = "home", title = "Home", icon = "angle double left"),
  list(id = "picture", title =  "Choose picture", icon = "angle double right")
)



tiles_callback <- function(input, output, session, tiles_path) {
  
  observeEvent(input$set, {
    tiles_path(file.path("tiles", input$set))
  })
  
  observeEvent(input$confirm_tags, {
    tiles_path(file.path("tiles", input$tags))
    prepare_tiles(input$tags)
  })
  
}

prepare_tiles <- function(tiles_tags) {
  size <- c(20, 20)
  tiles_path <- file.path("tile", tiles_tags)
  message("downloading data")
  for (tile_tag in tiles_tags) {
    tile_path <- file.path("tile", tile_tag)
    api_url <- httr::GET(glue::glue("https://api.creativecommons.engineering/v1/images/?q={tile_tag}&type=jpg&size=small&page_size=500&page=1"))
    images_meta <- content(api_url)$results
    urls <- images_meta %>% purrr::map_chr("url") %>% unique()
    
    unlink(tile_path, recursive = TRUE)
    dir.create(tile_path)
    download.file(urls, destfile = file.path(tile_path, basename(urls)))
  }
  
  message("resizing images")
  for (tile_tag in tiles_tags) {
    tile_path <- file.path("tile", tile_tag)
    target_path <- file.path("tiles", tile_tag)
    unlink(target_path, recursive = TRUE)
    dir.create(target_path)
    
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
  unlink(tiles_path, recursive = TRUE)
  message("done")
}
