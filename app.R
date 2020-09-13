library(shiny)
library(shiny.semantic)
library(shiny.router)
library(httr)
library(magrittr)
library(imager)
library(RsimMosaic)
library(shinywebcam)
library(shinysense)

source("modules/utils.R")
source("modules/home.R")
source("modules/picture.R")
source("modules/tiles.R")
source("modules/mosaic.R")

router <- make_router(
  route("home", hello_page),
  route("tiles", tiles_page, tiles_callback),
  route("picture", picture_page, picture_callback),
  route("mosaic", mosaic_page, mosaic_callback)
)

ui <- semanticPage(
  tags$head(
    tags$link(rel = "stylesheet", href = "style.css"),
    tags$link(rel = "stylesheet", href = "photo.css"),
    tags$script(src = "photo.js")
  ),
  router$ui,
  margin = 0
)

server <- function(input, output, session) {
  tiles_path <- reactiveVal(NULL)
  router$server(input, output, session, tiles_path = tiles_path)
}

shinyApp(ui, server)
