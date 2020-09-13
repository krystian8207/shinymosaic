divider <- function(..., class = "") {
  div(class = glue::glue("ui {class} divider"), ...)
}
column <- function(..., class = "") {
  div(class = glue::glue("{class} column"), ...)
}
row <- function(..., class = "") {
  div(class = glue::glue("{class} row"), ...)
}

standard_page_grid <- grid_template(default = list(
  areas = rbind(
    c("title", "title",   "title"),
    c("content", "content", "content"),
    c("prev_page",   "blankc",  "next_page")
  ),
  rows_height = c("20%", "60%", "20%"),
  cols_width = c("25%", "auto", "25%")
))

click_button <- function(input_id, label, icon = NULL, class = NULL, ...) {
  tags$a(id = input_id, class = paste("ui", class, "button"), 
              icon, " ", label, ...)
}

page <- function(id, title, content, prev_page, next_page) {
  if (!is.null(prev_page)) {
    prev_page <-  click_button(glue::glue("{id}-{prev_page$id}"), prev_page$title, class = "orange left labeled icon massive", 
                               icon = icon(prev_page$icon), href = route_link(prev_page$id), style = "font-size: 2.5rem;")
  }
  if (!is.null(next_page)) {
    next_page = click_button(glue::glue("{id}-{next_page$id}"), next_page$title, class = "orange right labeled icon massive disabled",
                             icon = icon(next_page$icon), href = route_link(next_page$id), style = "font-size: 2.5rem;")
  }
    
  div(
    grid(standard_page_grid,
         container_style = "padding: 10%;",
         blankc = div(""),
         title = div(class = "ui center aligned basic segment", div(class = "ui header", style = "font-size: 4em;", title)),
         content = div(content),
         prev_page = prev_page,
         next_page = next_page
    ) 
  )
}
