#------------------------------ Check Run_Info for Errors ------------------------------#
#*********** Check run_info for errors here **********#
data_prep_log <- lapply(school_data_list, function(school) {
  return(school[["run_info"]])
})

# Extract each data piece from the list
rawData_report_parts <- lapply(school_data_list, function(school) {
  return(school[["rawData_report_parts"]])
})
school_grade_bands <- lapply(school_data_list, function(school) {
  return(school[["school_grade_bands"]])
})
staff_survey_respondents <- lapply(school_data_list, function(school) {
  return(school[["staff_survey_respondents"]])
})

school_metrics_data <- lapply(school_data_list, function(school) {
  return(school[["school_metrics_data"]])
})

school_individual_ratings_data <- lapply(school_data_list, function(school) {
  return(school[["indicator_ratings"]])
})

# Combine each data piece into a single dataframe
rawData_report_parts <- do.call(bind_rows, rawData_report_parts)
school_grade_bands <- do.call(bind_rows, school_grade_bands)
staff_survey_respondents <- do.call(rbind, staff_survey_respondents)
school_metrics_data <-  do.call(rbind, school_metrics_data)
school_individual_ratings_data <-  do.call(rbind, school_individual_ratings_data)

rm(school_data_list)

print_warning("\n\nPreparing data:")

pb1 <- progress_bar$new(
  format = "\r     [:bar] :percent | time elapsed: :elapsed | eta: :eta",
  total = nrow(reports),
  show_after = 0,
  force = TRUE,
  clear = FALSE
)
progress1 <- function(n) {
  pb1$tick()
}
opts1 <- list(progress = progress1)
# Create progress bar before first iteration
invisible(pb1$tick(0))


