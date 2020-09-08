library(shiny)
library(shinysense)

ui <- fluidPage(
  shinyviewr_UI("photo"),
  imageOutput("photoop")
)

server <- function(input, output, session) {
  camera_snapshot <- callModule(shinyviewr, 'photo', output_width = 400)
  trigger <- reactiveVal(NULL)
  observeEvent(camera_snapshot(), {
    png(filename="cam.png")
      plot(camera_snapshot(), main = 'My Photo!')
    dev.off()
    trigger(runif(1))
  })
  
  output$photoop <- renderImage({
    req(trigger())
    list(src = "cam.png")
  }, deleteFile = FALSE)
}

shinyApp(ui, server)