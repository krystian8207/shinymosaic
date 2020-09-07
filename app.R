library(shiny)
library(shiny.semantic)
library(shiny.router)
library(httr)
library(magrittr)
library(imager)
library(RsimMosaic)
library(shinywebcam)

source("modules/utils.R")
source("modules/picture.R")
source("modules/tiles.R")

# Both sample pages.
hello_page <- page(
  "home",
  "Home page",
  "Welcome to mosaic image creator!",
  NULL, 
  list(id = "tiles", title =  "Start", icon = "angle double right")
)

mosaic_page <- page(
  "mosaic",
  "Confirm mosaic", 
  "Click to confirm", 
  list(id = "picture", title =  "Choose picture", icon = "angle double left"),
  list(id = "home", title = "Try again!", icon = "undo")
)

# Creates router. We provide routing path, a UI as
# well as a server-side callback for each page.
router <- make_router(
  route("home", hello_page),
  route("tiles", tiles_page, tiles_callback),
  route("picture", picture_page, picture_callback),
  route("mosaic", mosaic_page)
)

ui <- semanticPage(
  router$ui
)

server <- function(input, output, session) {
  tiles_path <- reactiveVal(NULL)
  router$server(input, output, session, tiles_path = tiles_path)
}

shinyApp(ui, server)
