get_update_text_filename <- function(report_name, full_name = FALSE) {
  # Define possible suffixes
  cleaned_report_name <- gsub("-", "", report_name)

  folder_path <- paste0("Data/Text_Files")

  # List files in the folder
  files <- list.files(path = folder_path, full.names = full_name)

  # Compute string distances between cleaned report name and file names
  distances <- stringdist::stringdist(cleaned_report_name, files, method = "jaccard")

  # Find the index of the file with minimum distance
  min_index <- which.min(distances)

  # Check if the minimum distance is within an acceptable threshold
  if (distances[min_index] <= 0.5) { # Adjust the threshold as needed
    found_file <- files[min_index]
  } else {
    found_file <- NULL
  }
  return(found_file)
}

find_update_text <- function(report_name) {
  found_file <- get_update_text_filename(report_name, full_name = TRUE)
  # print("Update Text File")
  # print(paste("report name is:", report_name))
  # print(paste("updateText file that was found:" , found_file))
  # Check if report_name is not in found_file
  if (is.null(found_file)) {
    return(NULL)
  }
  if (!grepl(report_name, found_file)) {
    # print("report name is not in found file")
    # print_error("Stopping this reort run: Need to fix UpdateText file name")
    return(NULL)
  }
  if (!is.null(found_file)) {
    sheet_names <- excel_sheets(found_file)
    if ("UpdateText" %in% sheet_names) {
      update_text <- read_excel(found_file, sheet = "UpdateText")
      ### print("UpdateText sheet found")
    } else {
      update_text <- read_excel(found_file, sheet = 1)
      ### print("UpdateText sheet not found, reading from the first sheet")
    }
    return(update_text)
  } else {
    return(NULL)
  }
}

perform_safety_checks <- function(report, found_file) {
  name_school_district <- report
  #------------------------------ Prepare Folder Names and School and District Name -------------------------------#
  split_string <- strsplit(report, "- ")
  # Extract the first part
  school_name <- split_string[[1]][1]
  district_name <- str_trim(split_string[[1]][2])

  ### print(district_name)
  if (district_name %in% found_file) {
    ### print("distric name is in found file")
    return(TRUE)
  } else {
    ### print("distric name is not in found file")
    return(NULL)
  }

  ## TODO: Should I build out check for school file names?
}
