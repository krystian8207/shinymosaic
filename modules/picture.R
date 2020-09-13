file_input <- fileInput("image_upload", "Upload your image")
file_input$attribs$style <- "display:none;"

file_input_button <- tags$button(
  class = "ui button", onclick = "$('#image_upload').click()", 
  style = "width: 100%; max-width: 100%;", icon("upload"), "Upload image"
)

picture_page <- page(
  "picture",
  "Choose photo",
  segment(
    class = "placeholder",
    div(
      class = "ui two column stackable center aligned grid",
      divider(class = "vertical"),
      row(
        class = "middle aligned", 
        column(
          file_input,
          file_input_button,
          divider(class = "horizontal", "OR"),
          actionButton("takeaphoto", "Use webcam", icon = icon("video"), style = "width: 100%; max-width: 100%;")
        ),
        column(
          div(id = "image_message", class = "center aligned", "Select one of two options to choose your photo"),
          HTML('<div id="contentarea">
        <div class="camerainput ui primary centered orange card">
          <div class = "image">
            <video id="video" class = "image">Video stream not available.</video>
          </div>  
          <div class="ui bottom attached button" id="startbutton">
              <i class="camera icon"></i>
                Take photo
          </div>
          <canvas id="canvas"></canvas>
        </div>
        <div class="photooutput ui primary centered orange card">
          <div class = "image">
            <img id="photo" alt="The screen capture will appear in this box."> 
          </div>
          <div class="ui bottom attached button" id="again">
              <i class="redo icon"></i>
                Retry
          </div>
        </div>
        <div class="uploadoutput ui primary centered orange card">
          <div class = "image" style = "height: auto;">
            <div id="photo_view" class="shiny-image-output image" style="height: auto"></div> 
          </div>
          <div class="content">
            <div class="header center aligned shiny-text-output" id="image_path"></div>
          </div>
        </div>
    </div>')
        )
      )
    )
  ),
  list(id = "home", title = "Home", icon = "angle double left"),
  list(id = "mosaic", title =  "Mosaic Me!", icon = "angle double right")
)

picture_callback <- function(input, output, session) {
  trigger <- reactiveVal(NULL)

  observeEvent(input$takeaphoto, {
    session$sendCustomMessage("take-photo", list(value = "run"))
  })
  
  observeEvent(input$data_url, {
    sent_image <- input$data_url %>% 
      gsub("data:image/png;base64,", "", ., fixed = TRUE) %>% 
      gsub(" ", "+", ., fixed = TRUE)
    file_path <- "www/cam.png"
    outconn <- file(file_path,"wb")
    base64enc::base64decode(what=sent_image, output=outconn)
    close(outconn)
    im <- load.image(file_path)
    out_width <- 200
    out_height <- floor(out_width / dim(im)[1] * dim(im)[2])
    im_input <- resize(im, out_width, out_height)
    imager::save.image(im_input, file = file_path)
    session$sendCustomMessage("toggle-next", list(id = "picture-mosaic", action = "pass"))
  })
  
  observeEvent(input$image_upload, {
    print("update")
    session$sendCustomMessage("show-upload", list(value = "run"))
    file <- input$image_upload$datapath
    im <- load.image(file)
    out_width <- 200
    out_height <- floor(out_width / dim(im)[1] * dim(im)[2])
    im_input <- resize(im, out_width, out_height)
    fin_file <- "www/cam.jpg"
    imager::save.image(im_input, file = fin_file)
    session$sendCustomMessage("toggle-next", list(id = "picture-mosaic", action = "pass"))
    trigger(input$image_upload)
  })
  
  output$photo_view <- renderImage({
    req(trigger())
    list(src = "www/cam.jpg")
  }, deleteFile = FALSE)
  outputOptions(output, "photo_view", suspendWhenHidden = FALSE)
  
  output$image_path <- renderText({
    req(trigger())
    trigger()$name
  })
  outputOptions(output, "image_path", suspendWhenHidden = FALSE)
  
}
