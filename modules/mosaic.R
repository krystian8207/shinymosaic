mosaic_page <- page(
  "mosaic",
  "Generate mosaic", 
  div(
    style = "text-align: center;",
    action_button("confirm_settings", "Run mosaic generator!", style = "width: 40%;  margin-top: 10%;", class = "red massive"), 
    imageOutput("mosaied", width = "100%", height = "auto"),
    uiOutput("download_image")
  ), 
  list(id = "picture", title =  "Choose picture", icon = "angle double left"),
  list(id = "home", title = "Try again!", icon = "undo", js = "setTimeout(location.reload.bind(location), 1);")
)

mosaic_callback <- function(input, output, session, tiles_path) {
  trigger_save <- reactiveVal(NULL)
  trigger_download <- reactiveVal(NULL)
  
  observeEvent(input$confirm_settings, {
    session$sendCustomMessage("toggle-next", list(id = "confirm_settings", action = "stop"))
    orig_file_out <- "www/final.jpg"
    tiles_path <- tiles_path()
    composeMosaicFromImageRandom("www/cam.jpg", orig_file_out, tiles_path, removeTiles=FALSE)
    trigger_save(runif(1))
  })
  
  output$mosaied <- renderImage({
    req(trigger_save())
    session$sendCustomMessage("toggle-view", list(id = "confirm_settings", action = "hide"))
    trigger_download(runif(1))
    list(src = "www/final.jpg")
  }, deleteFile = FALSE)
  
  output$download_image <- renderUI({
    req(trigger_download())
    session$sendCustomMessage("toggle-next", list(id = "mosaic-home", action = "pass"))
    tags$a(id = "download_img", "Download image", style = "width: 40%;", 
                  class = "ui red massive button shiny-download-link", icon("download"), download = NA, target = "_blank", href = "")
  })
  
  output$download_img <- downloadHandler(
    filename = "mosaic.jpg",
    contentType = "image/jpeg",
    content = function(file) {
      file.copy("www/final.jpg", file)
    }
  )
  
}
