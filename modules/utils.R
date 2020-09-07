standard_page_grid <- grid_template(default = list(
  areas = rbind(
    c("blankl", "title",   "blankr"),
    c("blanka", "content", "blankb"),
    c("prev_page",   "blankc",  "next_page")
  ),
  rows_height = c("100px", "300px", "200px"),
  cols_width = c("400px", "auto", "400px")
))

click_button <- function(input_id, label, icon = NULL, class = NULL, ...) {
  tags$a(id = input_id, class = paste("ui", class, "button"), 
              icon, " ", label, ...)
}

page <- function(id, title, content, prev_page, next_page) {
  if (!is.null(prev_page)) {
    prev_page <-  click_button(glue::glue("{title}-{prev_page$id}"), prev_page$title, class = "left labeled icon massive", 
                               icon = icon(prev_page$icon), href = route_link(prev_page$id))
  }
  if (!is.null(next_page)) {
    next_page = click_button(glue::glue("{title}-{next_page$id}"), next_page$title, class = "right labeled icon massive",
                             icon = icon(next_page$icon), href = route_link(next_page[1]))
  }
    
  div(
    grid(standard_page_grid,
         container_style = "border: 1px solid #000",
         blankl = div(""),
         blanka = div(""),
         blankb = div(""),
         blankr = div(""),
         blankc = div(""),
         title = div(title),
         content = div(content),
         prev_page = prev_page,
         next_page = next_page
    ) 
  )
}
