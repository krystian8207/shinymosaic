picture_page <- page(
  "picture",
  "Choose target image", 
  segment(
    div(
      class = "ui two column very relaxed grid", 
      div(class = "column", fileInput("image_upload", "Upload your image")),
      div(class = "column", tags$label("Take a photo"), actionButton("photomake", "Make"), div(id = "pht"))#, shinyviewr_UI("photo"))
    ),
    div(class = "ui vertical divider", "or"),
    imageOutput("photo_view")
  ), 
  list(id = "tiles", title = "Tiles", icon = "angle double left"),
  list(id = "mosaic", title =  "Mosaic Me!", icon = "angle double right")
)

picture_callback <- function(input, output, session) {
  
  observeEvent(input$photomake, {
    insertUI(
      selector = "#pht",
      where = "afterBegin",
      tagList(
        startWebcam(width = 320, height = 240, quality = 100),
        snapshotButton(),
        takeSnapshot()   
      )
    )
  })
  
  # camera_snapshot <- callModule(shinyviewr, 'photo', output_width = 400)
  # trigger <- reactiveVal(NULL)
  # observeEvent(camera_snapshot(), {
  #   png(filename="cam.png")
  #   plot(camera_snapshot(), main = 'My Photo!')
  #   dev.off()
  #   trigger(runif(1))
  # })
  # 
  # observeEvent(input$image_upload, {
  #   file <- input$image_upload
  #   file.copy(file, "cam.png")
  #   trigger(runif(1))
  # })
  # 
  # output$photo_view <- renderImage({
  #   req(trigger())
  #   list(src = "cam.png")
  # }, deleteFile = FALSE)
  
}
