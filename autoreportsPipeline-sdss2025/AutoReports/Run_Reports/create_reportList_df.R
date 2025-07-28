#------------------------------ CREATE DATAFRAMES USED BY SCHOOLS  ------------------------------#
# NOTE: Currently running in parallel, but errors are not being caught - may miss important errors on run
# Errors in Data_Prep should cause errors in report run, causing them to get caught for now
prepped_data <- prepData(rawData_report_parts, rawDataDict, reportFilter, school_grade_bands, staff_survey_respondents, reports_to_skip)


#------------------------------ (ABOVE) END OF DATAFRAME CREATION  ------------------------------#
reportList <- lapply(prepped_data, function(school) {
  return(school[["data"]])
})
data_backend_log <- lapply(prepped_data, function(school) {
  return(school[["log"]])
})
rm(prepped_data)
