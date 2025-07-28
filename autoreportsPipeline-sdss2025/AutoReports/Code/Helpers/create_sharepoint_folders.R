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
debug_local <- FALSE
# Use type to specify which report to run when there are multiple versions
# type <- "school"
reportFilter <- paste0(reportFilter, collapse = "|") # Turn vector into regex string

#------------------------------ CONFIGURATION ------------------------------#
source(file.path("config.R"))


# Corrected loop
# Corrected for loop
for(i in 1:nrow(school_name_activities)) {
  rcdts_key <- school_name_activities[i, 'key']
  school <- school_name_activities[i, 'name']
  district <- school_name_activities[i, 'district_name']
  
  # Replace spaces with underscores
  folder <- paste0("Output/", rcdts_key, "_", school, "_", district)
  makeFolders(folder)
}


