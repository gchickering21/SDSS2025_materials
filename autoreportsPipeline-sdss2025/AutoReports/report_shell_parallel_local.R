# AUTHOR: Graham Chickering
# Purpose: Run ILNA Auto Reports
# DATE CREATED:
# 03/05/2024
# UPDATED:
# NOTES:
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
#------------------------------ RUN CONTROLS -------------------------------#

# Leave this blank if you want to run all states
# Otherwise, this vector will be used to filter report names (using regex - case-insensitive)
reportFilter <- c("") # Note that this filter looks at school name, not RCDTS. School names are NOT unique
verbose <- FALSE # Set TRUE to see the individual schools and updateText_Files being run. FALSE still prints batch summary info
skip_reruns <- FALSE # Set TRUE to not re-generate reports already present inside the output folder
debug_local <- FALSE
# Use type to specify which report to run when there are multiple versions
# type <- "school"
reportFilter <- paste0(reportFilter, collapse = "|") # Turn vector into regex string

#------------------------------ CONFIGURATION ------------------------------#
source(file.path("config_local.R"))
if (skip_reruns) {
  # reports_to_skip <- paste0(getGeneratedReports(), collapse="|") #Currently pulls school names from output pdfs - may need to update to use RCDTS
  reports_to_skip <- "" # Currently removing this functionality until code is updated to use RCDTS
} else {
  reports_to_skip <- "^$"
}

#------------------------------ Clean Up Temp Files at Start------------------------------#
cleanFolders()
clearTemplatesLogFiles()

#------------------------------ Parallel Report Creation ------------------------------#
cat("\033[1;32mParalleization Report Creation Started\033[0m\n")
source(file.path("Run_Reports", "parallelization_report_creation_local.R"))
cat("\033[1;32mParalleization Report Creation Done\033[0m\n")


#------------------------------ Clean Up Temp Files ------------------------------#
# Clean up temp files
# cleanFolders(error_df)
# removeSchoolTempFolder()
