## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
# AUTHOR: Michael Kruse
# Purpose: Set global variables and read raw data for auto-reports pipeline
# DATE CREATED:
# 10/20/2023
# UPDATED:
# NOTES: To run a set number of reports (rather than listing the exact reports to be ran), keep reportFilter blank and limit the schools in report_shell.R
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------

#-------------------------------- PACKAGES ---------------------------------#

reqpkg <- c("aws.s3","ggtext","magick","pdftools","tidyverse", "readr", "dotenv", "readxl", "janitor", "tidyr", "dplyr", "scales", "ggplot2", "stringr", "ggtext", "ggrepel", "rjson", "configr", "RPostgres", "openxlsx", "stringdist", "doSNOW", "parallel", "foreach", "readxl", "progress", "dotenv", "reticulate", "officer", "magick")


for (pkg in reqpkg) {
  suppressPackageStartupMessages(require(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))
}
#---------------------------- SOURCE FUNCTION ------------------------------#
# Sources all files in the specified folders, as well as skipping specified files and including specified files from other folders
source_files <- function(folders, skip_files = c(), add_files = c()) {
  # Loads all .R files. Prints files on error while continuing to load all other files
  # Using lapply is a bit faster than for-loops. invisible() prevents anything being printed/returned by the lapply
  invisible(lapply(directories_to_load, function(folder) {
    invisible(lapply(c(list.files(folder, full.names = T), add_files), function(file) {
      tryCatch(
        {
          if (grepl("\\.R$", file, ignore.case = T)) {
            if (!gsub(".*\\/", "", file) %in% skip_files) {
              source(file)
            }
          } else if (grepl("\\.py$", file, ignore.case = T) & file != "__init__.py") {
            if (!gsub(".*\\/", "", file) %in% skip_files) {
              source_python(file)
            }
          }
        },
        error = function(e) {
          message(paste("\033[1;31mCould not source file:", file, "\n   ", e, "\nStopping...\033[0m\n\n"))
          stop()
        }
      )
    }))
  }))
}

#--------------------------------- SOURCE ----------------------------------#

if (debug_local == TRUE) {
  # Create a virtual environment named "ilna_python_env" using system Python
  virtualenv_create("ilna_python_env", python = "/usr/bin/python3")

  # Install required packages in this virtual environment
  reticulate::py_install(c("python-dotenv", "pyairtable"), envname = "ilna_python_env")
  reticulate::py_install(c("pandas"), envname = "ilna_python_env")

  # Use the created virtual environment
  use_virtualenv("ilna_python_env", required = TRUE)

  # Verify that reticulate is using the correct environment
  py_config()
}

tryCatch(
  {
    dotenv::load_dot_env()
  },
  error = function(e) {
    cat("\033[1;31m", e, "\033[0m\n")
  }
)
#### Files to ignore loading
skip_files <- c("install_missing_packages.py", "send_ses_email.py", "sharepoint_automation.py", "create_sharepoint_folders.R", "read_from_database.R")
#### Files to include loading (from other directories)
add_files <- c()

#### Directories to load (calls source() on all .R files in each folder)
directories_to_load <- c(
  file.path("Code", "Data_Prep"),
  file.path("Code", "Figure_Generation"),
  file.path("Code"),
  file.path("Code", "Helpers")
)

source_files(directories_to_load, skip_files, add_files)

#-------------------------------- READ DATA --------------------------------#

#------Static Text Data ------#
# Data dictionary
rawDataDict <- read_excel("Data/Raw_Data_Files/data_dict6.xlsx")
reportData <-  readRDS("Data/Mock_Data/reportData.rds")
# Step 2: Define the names you want to assign
new_names <- c(
  "tbl0", "ind1a", "tbl1a", "fig1a", "ind1b", "tbl1b", "fig1b", "ind1c", "tbl1c", "fig1c.1", "fig1c.2",
  "ind1d", "tbl1d", "fig1d.1", "fig1d.2", "ind2a", "fig2a", "ind2b", "tbl2b", "fig2b.1", "fig2b.2", "ind2c",
  "tbl2c.1", "tbl2c.2", "tbl2c.3", "fig2c", "ind2d", "fig2d", "ind2e", "fig2e.1", "fig2e.2", "ind3a", "tbl3a",
  "fig3a", "ind3b", "tbl3b.1", "tbl3b.2", "tbl3b.3", "tbl3b.4", "tbl3b.5", "fig3b", "ind3c", "tbl3c", "fig3c",
  "ind3d", "tbl3d", "fig3d.1", "fig3d.2", "ind3e", "fig3e", "ind4a", "fig4a", "ind4b", "tbl4b.1", "tbl4b.2",
  "tbl4b.3", "fig4b", "ind4c", "fig4c.1", "fig4c.2", "ind4d", "fig4d"
)

# Step 3: Assign the names to the list
names(reportData) <- new_names
class_obs_bullets_school <- readRDS("Data/Mock_Data/class_obs_bullets_school.rds")


class_obs_k_3_aggregate <-read_csv("Data/Mock_Data/mock_class_obs_k_3_aggregate.csv")
class_obs_secondary_aggregate <- read_csv("Data/Mock_Data/mock_class_obs_secondary_aggregate.csv")
class_obs_upper_elementary_aggregate <- read_csv("Data/Mock_Data/mock_class_obs_upper_elementary_aggregate.csv")
database_school_metrics_combined <- read_csv("Data/Mock_Data/mock_database_school_metrics_combined.csv")

#------ CLASS Static Language------#
dynamic_text <- read_csv("Data/Mock_Data/mock_dynamic_text.csv")
#------ Indicator Ratings ------#
initial_draft_report <- read_csv("Data/Mock_Data/mock_initial_draft_report.csv")
ind_ratings <- read_csv("Data/Mock_Data/mock_ind_ratings.csv")
school_metrics <- read_csv("Data/Mock_Data/mock_school_metrics.csv")


#------ YR 2_IL NA School Information, SchoolPartsList ------#
report_parts <- read_csv("Data/Mock_Data/mock_report_parts.csv")

# This is used for the grade bands that are used in Class Observation Figures
grade_bands <- read_csv("Data/Mock_Data/mock_grade_bands.csv")

# #------ Version Sheet------#
version_sheet <- read_csv("Data/Mock_Data/mock_version_sheet.csv")

#------  Schools Like Us Data ------#
files <- list.files("Data/Schools_Like_US", pattern = "\\.csv")
# Read CSV files and apply gsub to each data frame
schools_like_us_list <- lapply(paste0("Data/Schools_Like_US/", files), function(file) {
  # Use read_csv instead of read.csv for more robust reading
  data <- read_csv(file, show_col_types = FALSE)
  
  # Replace spaces in column names with periods
  names(data) <- gsub(" ", ".", names(data))
  
  # Convert RCDTS column to character if it exists
  if ("RCDTS" %in% names(data)) {
    data$RCDTS <- as.character(data$RCDTS)
  }
  
  # Convert to data frame if cleanup_school_names expects base R df
  data <- as.data.frame(data)
  
  # Apply your custom cleaning function
  data <- cleanup_school_names(data, "dist_school")
  
  return(data)
})



#------ Class Obs Bullets from DB ------#
class_obs_bullets <- read_csv("Data/Mock_Data/mock_class_obs_bullets.csv")