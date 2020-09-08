mosaic_page <- page(
  "mosaic",
  "Confirm mosaic", 
  div(actionButton("confirm_settings", "Confirm"), imageOutput("mosaied", width = "300px")), 
  list(id = "picture", title =  "Choose picture", icon = "angle double left"),
  list(id = "home", title = "Try again!", icon = "undo")
)

mosaic_callback <- function(input, output, session, tiles_path) {
  trigger_save <- reactiveVal(NULL)
  
  observeEvent(input$confirm_settings, {
    orig_file_out <- "www/final.jpg"
    # todo handle multiple tiles
    tiles_path <- tiles_path()
    message("mosaicing started")
    composeMosaicFromImageRandom("www/cam.jpg", orig_file_out, tiles_path, removeTiles=FALSE)
    trigger_save(runif(1))
  })
  
  output$mosaied <- renderImage({
    req(trigger_save())
    list(src = "www/final.jpg")
  }, deleteFile = FALSE)
}
