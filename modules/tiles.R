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
            div(class = "ui icon header", icon("mouse pointer"), span(class = "ui large text", "Select ready set")),
            div(
              class = "ui massive form",
              multiple_radio(
                "set", NULL, 
                choices = c("dogs", "cats", "cars"), position = "inline",
                selected = NULL
              )
            )
          ),
          column(
            div(class = "ui icon header", icon("world"), span(class = "ui large text", "Create your own")),
            div(
              class = "field",
              shiny.semantic::uiinput(
                `data-tooltip` = "Images will be downloaded using https://api.creativecommons.engineering/v1 API",
                class = "big right labeled left icon", icon("tags"), text_input(input_id = "tags", placeholder = "Enter tag"), 
                button("confirm_tags", "Confirm tag", class = "tag label")
              )
            )
          )
        )
      )
    ),
    uiOutput("progress_message")
  ),
  list(id = "home", title = "Home", icon = "angle double left"),
  list(id = "picture", title =  "Choose picture", icon = "angle double right")
)



tiles_callback <- function(input, output, session, tiles_path, user_path) {

  observeEvent(input$confirm_tags, {
    req(input$confirm_tags)
    session$sendCustomMessage("toggle-next", list(id = "tiles-picture", action = "stop"))
    output$progress_message <- renderUI({
      with_progress({
        tiles_path(file.path(user_path, "tiles", input$tags))
        prepare_tiles(input$tags, user_path, session)
        div(
          class = "ui massive floating message", 
          sprintf("Selected collection: %s", input$tags), 
          style = "text-align: center;"
        )
      }, value = 0, message = "Starting creating tiles")
    })
    session$sendCustomMessage("clear-checkbox", list(id = "set"))
  })
  
  observeEvent(input$set, {
    req(input$set)
    tiles_path(file.path("tiles", input$set))
    output$progress_message <- renderUI({
        div(
          class = "ui massive floating message", 
          sprintf("Selected collection: %s", input$set), 
          style = "text-align: center;"
        )
    })
    session$sendCustomMessage("toggle-next", list(id = "tiles-picture", action = "pass"))
  }, ignoreNULL = TRUE)
}

prepare_tiles <- function(tiles_tags, user_path, session) {
  size <- c(20, 20)
  dir.create(file.path(user_path, "tile"))
  tiles_path <- file.path(user_path, "tile", tiles_tags)
  set_progress(value = 0.1, message = "Downloading data..", session = session)
  for (tile_tag in tiles_tags) {
    tile_path <- file.path(user_path, "tile", tile_tag)
    api_url <- httr::GET(glue::glue("https://api.creativecommons.engineering/v1/images/?q={tile_tag}&type=jpg&size=small&page_size=500&page=1"))
    images_meta <- content(api_url)$results
    urls <- images_meta %>% purrr::map_chr("url") %>% unique()
    
    unlink(tile_path, recursive = TRUE)
    dir.create(tile_path)
    download.file(urls, destfile = file.path(tile_path, basename(urls)))
  }
  set_progress(value = "0.5", message = "Resizing images..", session = session)

  message("resizing images")
  for (tile_tag in tiles_tags) {
    tile_path <- file.path(user_path, "tile", tile_tag)
    target_path <- file.path(user_path, "tiles", tile_tag)
    unlink(file.path(user_path, "tiles"), recursive = TRUE)
    dir.create(file.path(user_path, "tiles"))
    unlink(target_path, recursive = TRUE)
    dir.create(target_path)
    
    for (img in list.files(tile_path, pattern = "jpg")) {
      im <- load.image(file = file.path(tile_path, img))
      if (dim(im)[4] != 3) {
        next
      }
      thmb <- resize(im, size[1], size[2])
      imager::save.image(thmb, file = file.path(target_path, img))
    }
  }
  unlink(tiles_path, recursive = TRUE)
  set_progress(value = 0.8, message = "Saving images..", session = session)
  session$sendCustomMessage("toggle-next", list(id = "tiles-picture", action = "pass"))
}
