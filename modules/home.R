home_page_grid <- grid_template(default = list(
  areas = rbind(
    c("blankt", "blankt", "blankt"),
    c("blankl", "start",  "blankr")
  ),
  rows_height = c("80%", "20%"),
  cols_width = c("40%", "auto", "40%")
))

hello_page <-   div(
  grid(home_page_grid,
       blankl = div(""),
       blankt = div(""),
       blankb = div(""),
       blankr = div(""),
       start = click_button(
         glue::glue("home-tiles"), "Start", class = "orange fluid  massive",
         href = route_link("tiles"), style = "font-size: 2.5rem;"
       )
  ) 
)
