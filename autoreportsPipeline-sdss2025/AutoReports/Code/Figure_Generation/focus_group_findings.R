detectBulletColumns <- function(df, column_name, variable_name) {
  variables <- df %>%
    filter(str_detect(df[[column_name]], variable_name))

  variables[[column_name]] <- gsub("%", " percent", variables[[column_name]], fixed = TRUE)
  return(variables)
}

createItemsFromColumn <- function(df, column_name, variable_name) {
  variables <- detectBulletColumns(df, column_name, variable_name)
  # Ensure the column exists in the dataframe
  if (!column_name %in% names(df)) {
    stop("Column name not found in the dataframe")
  }

  if (nrow(variables) == 0) {
    items <- c()
  } else {
    # Iterate over each row of the dataframe
    items <- lapply(1:nrow(variables), function(i) {
      # Extract the value from the specified column for the current row
      value <- variables[i, "Text"]

      if (is.na(value) || value == "NA" || value == " " || value == "" || value == "NANANA") {
        return(NULL) # This effectively skips the iteration
      } else {
        # Create the \item entry with the extracted value
        item <- paste0("\\item ", value, "")

        return(item)
      }
    })
  }




  if (length(items) == 0) {
    itemsText <- ""
  } else {
    # Filter out NULL values if any, to clean up the list
    items <- Filter(Negate(is.null), items)
    # Combine all the \item entries into a single character vector
    itemsText <- paste(items, collapse = "\n")
  }

  itemsText <- gsub("\r\n", "\n", itemsText)
  itemsText <- gsub("\n\n", "\n", itemsText)


  # Optionally, you can print the result or return it for further use
  return(itemsText)
}
