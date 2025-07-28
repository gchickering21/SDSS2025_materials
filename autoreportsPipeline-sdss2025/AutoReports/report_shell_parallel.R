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
debug_local <- TRUE
# Use type to specify which report to run when there are multiple versions
# type <- "school"
reportFilter <- paste0(reportFilter, collapse = "|") # Turn vector into regex string

#------------------------------ CONFIGURATION ------------------------------#
source(file.path("config.R"))
if (skip_reruns) {
  # reports_to_skip <- paste0(getGeneratedReports(), collapse="|") #Currently pulls school names from output pdfs - may need to update to use RCDTS
  reports_to_skip <- "" # Currently removing this functionality until code is updated to use RCDTS
} else {
  reports_to_skip <- "^$"
}

#------------------------------ Clean Up Temp Files at Start------------------------------#
cleanFolders()
clearTemplatesLogFiles()

#------------------------------ SETUP PARALLEL CONFIGURATION ------------------------------#
source(file.path("Run_Reports", "parallelization_config.R"))
cat("\033[1;32mParallelization Config Setup Done\033[0m\n")
#------------------------------ Prepare Text ------------------------------#
source(file.path("Run_Reports", "prepare_text.R"))
cat("\033[1;32mPrepare Text Done Done\033[0m\n")

#------------------------------ EARLY WARNING CHECKS: OASIS + AIRTABLE FORM FILLED OUT ------------------------------#
source(file.path("Run_Reports", "oasis_airtable_warning_check.R"))
cat("\033[1;32mEarly Warning Check: OASIS + Airtable Done\033[0m\n")

#------------------------------ Starting ILNA Report Run ------------------------------#
source(file.path("Run_Reports", "start_report_run.R"))
cat("\033[1;32mStarting Run of Report Done\033[0m\n")
#------------------------------ Data_Preparation for Each School ------------------------------#
source(file.path("Run_Reports", "parallelization_data_prep.R"))
cat("\033[1;32mData_Prep for Each School Done\033[0m\n")

#------------------------------ Check Run_Info for Errors ------------------------------#
source(file.path("Run_Reports", "check_run_info_for_errors.R"))
cat("\033[1;32mCheck Run Info For Errors Done\033[0m\n")

#------------------------------ Compile Data Frame ------------------------------#
source(file.path("Run_Reports", "create_reportList_df.R"))
cat("\033[1;32mCreating ReportList DF DONE \033[0m\n")

#------------------------------ Parallel Report Creation ------------------------------#
source(file.path("Run_Reports", "parallelization_report_creation.R"))
cat("\033[1;32mParalleization Report Creation Done\033[0m\n")

# Remove log entries for schools without errors/warnings
# data_prep_log <- data_prep_log[sapply(data_prep_log, function(x){length(x)!=0})]
# data_backend_log <- data_backend_log[sapply(data_backend_log, function(x){length(x)!=0})]
# file_run_info <- file_run_info[sapply(file_run_info, function(x){length(x)!=0})]
# report_run <- report_run[sapply(report_run, function(x){length(x)!=0})]

#------------------------------ Combine Warnings + Errors ------------------------------#
source(file.path("Run_Reports", "combine_error_logs.R"))

#------------------------------ Print Batch Info and Errors ------------------------------#
# Print batch info and errors encountered
source(file.path("Run_Reports", "print_batch_info_and_errors.R"))

#------------------------------ Clean Up Temp Files ------------------------------#
# Clean up temp files
cleanFolders(error_df)
# removeSchoolTempFolder()
