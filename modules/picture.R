picture_page <- page(
  "picture",
  "Choose target image", 
  segment(
    div(
      class = "ui two column very relaxed grid", 
      div(class = "column", fileInput("image_upload", "Upload your image")),
      div(class = "column", tags$label("Take a photo"), actionButton("photomake", "Make"), shinyviewr_UI("photo"))
    ),
    div(class = "ui vertical divider", "or"),
    imageOutput("photo_view")
  ), 
  list(id = "tiles", title = "Tiles", icon = "angle double left"),
  list(id = "mosaic", title =  "Mosaic Me!", icon = "angle double right")
)

picture_callback <- function(input, output, session) {
  trigger <- reactiveVal(NULL)
  #file_path <- reactiveVal(NULL)
  
  camera_snapshot <- callModule(shinyviewr, 'photo', output_width = 400)
  observeEvent(camera_snapshot(), {
    jpeg(filename="www/cam.jpg")
    par(mar = rep(0, 4))
    plot(camera_snapshot(), main = 'My Photo!')
    dev.off()
    im <- load.image("www/cam.jpg")
    out_width <- 150
    out_height <- floor(out_width / dim(im)[1] * dim(im)[2])
    im_input <- resize(im, out_width, out_height)
    fin_file <- "www/cam.jpg"
    imager::save.image(im_input, file = fin_file)
    trigger(runif(1))
  })
  
  observeEvent(input$image_upload, {
    print("update")
    file <- input$image_upload$datapath
    im <- load.image(file)
    out_width <- 150
    out_height <- floor(out_width / dim(im)[1] * dim(im)[2])
    im_input <- resize(im, out_width, out_height)
    fin_file <- "www/cam.jpg"
    imager::save.image(im_input, file = fin_file)
    trigger(runif(1))
  })
  
  output$photo_view <- renderImage({
    req(trigger())
    list(src = "www/cam.jpg")
  }, deleteFile = FALSE)
  
}
