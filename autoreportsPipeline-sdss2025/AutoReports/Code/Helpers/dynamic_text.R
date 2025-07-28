report_indicator_text <- function(text_file, report_indicator, rating) {
  # Filter the data based on report_indicator and rating
  filtered_data <- text_file %>%
    filter(Indicator == report_indicator & Rating == rating)
  # Check if the filtered data is not empty
  if (nrow(filtered_data) > 0) {
    # Return the text column from the filtered data
    filtered_data_frame <- as.data.frame(filtered_data$Text)
    names(filtered_data_frame) <- "Text"
    return(filtered_data_frame)
  } else {
    # Return a message if no matching rows are found
    return("No matching data found.")
  }
}

report_indicator_text_intro <- function(text_file, report_indicator, rating, grade_type = "", separate_intro = FALSE) {

  report_indicator<- paste0(report_indicator,"Intro")
  if (separate_intro == TRUE){
    # Parse out the grade type
    grade_type2 <- ifelse(
      grepl("UPPER", grade_type), "UE",
      ifelse(grepl("SECONDARY", grade_type), "Sec", "Elem")
    )
    report_indicator<- paste0(report_indicator,grade_type2)
  }

  # Filter the data based on report_indicator and rating
  filtered_data <- text_file %>%
    filter(Indicator == report_indicator & Rating == rating)
  # Check if the filtered data is not empty
  if (nrow(filtered_data) > 0) {
    # Return the text column from the filtered data
    filtered_data_frame <- as.data.frame(filtered_data$Text)
    names(filtered_data_frame) <- "Text"
    return(filtered_data_frame)
  } else {
    # Return a message if no matching rows are found
    return("No matching data found.")
  }
}
