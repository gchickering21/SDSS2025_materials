cleanFolders <- function(error_df = NULL) {
  # specify file extensions to be removed in main directory <- not sure which of these are actually being created as of right now
  filetypes <- c(
    ".log", ".vrb", ".nav", ".snm", ".toc", "-tikzDictionary",
    ".synctex.gz", ".xmpdata", ".aux", ".out", ".gz", ".xmpi"
  )

  remove_files_base <- paste0("\\", filetypes, "$", collapse = "|")
  # Want to kep the csv to send email even if no errors are found
  # remove_files_base <- paste0(remove_files_base,'|batch_log\\.csv$')

  # find all files matching the extensions and remove
  files <- list.files(pattern = remove_files_base, full.names = TRUE)

  # keep .log files if report run encountered warnings or errors
  if (!is.null(error_df)) {
    if (any(error_df$errors)) {
      # schools <- sapply(report_run,function(log) {
      #   gsub('Iteration [0-9]* \\| |- [^-]*$','',str_extract(log,'(Iteration [0-9]* \\| )([^\\(*]*)(?= \\([0-9]+\\):)'))
      # })
      schools <- error_df$school_name[error_df$errors == TRUE]
      for (school in schools) {
        files <- files[!grepl(school, files, ignore.case = T)]
      }
      files <- files[!grepl("batch\\.log|batch_log\\.csv", files)]
    }
  }
  for (file in files) {
    file.remove(file)
  }
  cleanEmptyOutput()
}

cleanEmptyOutput <- function() {
  for (curr_file in list.files("Output", full.names = TRUE)) {
    if (length(list.files(curr_file)) == 0) {
      file.remove(curr_file)
    }
  }
}

cleanIntermediates <- function(report) {
  filetypes <- c(".log", ".pdf", ".sty", ".rmd", ".md")

  remove_files_regex <- paste0("^(mystyles_|report_.*_)*", report, "\\", filetypes, "$", collapse = "|")
  for (file in list.files(pattern = remove_files_regex, full.names = TRUE)) {
    file.remove(file)
  }
}

removeTexOutputFiles <- function(school_folder, report) {
  filetypes <- c(
    ".log", ".vrb", ".nav", ".snm", ".toc", "-tikzDictionary",
    ".synctex.gz", ".xmpdata", ".aux", ".out", ".gz", ".xmpi"
  )

  # specify file extensions to be removed in the output folder
  remove_files_output <- paste0("^", escape_name(report), "\\", c(filetypes, ".tex"), "$", collapse = "|")

  # find all files matching the extensions and remove ("folder" is a global variable)
  for (file in list.files(school_folder, pattern = remove_files_output, full.names = TRUE)) {
    file.remove(file)
  }
}

removeTempFolder <- function(error_df = NULL) {
  # remove temp files created for reports if no errors were encountered during run
  if (!is.null(error_df)) {
    if (!any(error_df$errors)) {
      unlink(file.path("Data", "Temp"), recursive = TRUE)
    }
  }
}

clearTemplatesLogFiles <- function() {
  # Remove all log files in the Templates/tables directory
  log_files <- list.files("Templates/tables", pattern = "\\.log$", full.names = TRUE)
  for (log_file in log_files) {
    file.remove(log_file)
  }
}


removeSchoolTempFolder <- function() {
  # Define the path to the main directory
main_dir <- "Output"

# List all subdirectories inside the main directory
school_dirs <- list.dirs(main_dir, recursive = FALSE)

# Iterate through each school directory
for (school_dir in school_dirs) {
  # Construct the path to the Temp folder
  temp_dir <- file.path(school_dir, "Temp")
  
  # Check if the Temp folder exists
  if (dir.exists(temp_dir)) {
    # Remove the Temp folder and its contents
    unlink(temp_dir, recursive = TRUE)
    cat("Removed Temp folder in:", school_dir, "\n")
  } else {
    cat("No Temp folder found in:", school_dir, "\n")
  }
}

cat("Cleanup complete!")
}

makeFolders <- function(folder) {
  if (!dir.exists(file.path(folder))) {
    dir.create(file.path(folder), recursive = TRUE)
  }
  path <- folder
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
}

# Get list of reports already generated to insert into regex
getGeneratedReports <- function(folder = "Output") {
  generated_reports <- list.files(folder, pattern = ".pdf", recursive = TRUE)
  generated_reports <- generated_reports[!grepl("_sample output", generated_reports)] # Ignore the sample output folder
  generated_reports <- gsub(".pdf", "", generated_reports) # Remove file extension
  generated_reports <- paste0("^", generated_reports, "$") # Add start/end markers to ensure exact matches
  return(generated_reports)
}

# Function to print error message in red
print_error <- function(message) {
  cat("\033[1;31m", message, "\033[0m\n")
}

print_warning <- function(message) {
  cat("\033[1;33m", message, "\033[0m\n")
}

make_error_msg <- function(message) {
  return(paste0("\033[1;31m", message, "\033[0m\n"))
}

make_warning_msg <- function(message) {
  return(paste0("\033[1;33m", message, "\033[0m\n"))
}
clean_msg <- function(message) {
  return(gsub("\033\\[[0-9]+m", "", message))
}

escape_name <- function(name) {
  # name <- gsub('(?<!\\)\\(?!\\)','\\\\',name, perl=T)
  # Escape parenthesis with backslashes
  name <- gsub("(\\(|\\))", "\\\\\\1", name, perl = T)
}
