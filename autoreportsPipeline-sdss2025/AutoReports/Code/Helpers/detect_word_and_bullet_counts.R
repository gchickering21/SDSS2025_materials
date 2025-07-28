count_num_bullets <- function(input_string) {
  count <- str_count(input_string, "\\\\item")
  return(count)
}

count_num_footnotes <- function(input_string) {
  count <- str_count(input_string, "\\\\node")
  return(count)
}

dynamic_place <- function(..., lheight = 12, y = -150, header = F) {
  #' Calculate y position of an object placed below many texts of dynamic length
  #' @param y Initial y value
  #' @param lheight Line height
  #' @param ... Any strings that will affect placement

  args <- list(...)
  for (input_string in args) {
    # print(input_string)
    line_count <- round(nchar(enc2utf8(input_string)) / 105)
    # print(line_count)
    y <- y - line_count * lheight
  }

  y <- y - 15

  return(y)
}

table_height <- function(table, notes = character(0), rheight = 15, footnoteHeight = 12) {
  #' Calculate height of a table to support dynamic text placement
  #' @param table data.frame Data to be placed in a table
  #' @param notes Any notes to be appended to the table
  #' @param rheight Row height

  number_of_footnotes <- 0 # Define the number_of_footnotes variable
  number_of_footnotes <- if (length(notes) == 0) {
    1
  } else {
    count_num_footnotes(notes) + 1
  }

  footnote_line_count <- round(nchar(enc2utf8(notes)) / 105)
  table_height <- rheight * nrow(table) + 40
  extra_lines <- max(footnote_line_count - number_of_footnotes, 0)
  footnote_height <- footnoteHeight * number_of_footnotes + extra_lines * footnoteHeight
  spacing <- table_height + footnote_height + 10

  return(spacing)
}


bullet_height <- function(notes = character(0), rheight = 10) {
  num_bullets <- count_num_bullets(notes)
  if (num_bullets == 0) {
    return(20)
  } else {
    line_count <- round(nchar(enc2utf8(notes)) / 90)
    bullet_height <- rheight * line_count + 5 * num_bullets
    return(bullet_height - 10)
  }
}
