#------------------------------ Combine Warnings + Errors ------------------------------#
# Combine multiple warnings/errors from each school into one string
data_prep_log <- lapply(data_prep_log, function(x) {
  paste0(x, collapse = "---\n")
})
data_backend_log <- lapply(data_backend_log, function(x) {
  paste0(x, collapse = "---\n")
})
file_run_info <- lapply(file_run_info, function(x) {
  paste0(x, collapse = "---\n")
})
report_run <- lapply(report_run, function(x) {
  paste0(x, collapse = "---\n")
})
# Combine into dataframe
error_df <- report_info %>%
  bind_cols(
    "data_prep_log" = unlist(data_prep_log),
    "data_backend_log" = unlist(data_backend_log),
    "file_gen_log" = unlist(file_run_info),
    "report_gen_log" = unlist(report_run)
  ) %>%
  mutate("pipeline_log" = "") # Add pipeline log column to be able to add pipeline errors if present

# Create a new column that combines all error/warnings for a report into one string, with a delimiter of '---\n':
error_df <- error_df %>% mutate(combined_log = paste0(data_prep_log, "---\n", data_backend_log, "---\n", file_run_info, "---\n", report_run))

# Clean up combined error string
error_df <- error_df %>%
  mutate(combined_log = gsub("(---\\n)+", "---\\\n", combined_log)) %>%
  mutate(combined_log = gsub("^---\\n|---\\n$", "", combined_log)) %>%
  mutate()

# Separate out errors and warnings
combined_error_log <- sapply(error_df$combined_log, function(log) {
  if (grepl("\\*\\*ERROR", log)) {
    return(paste0(unlist(str_extract_all(log, "\\*\\*ERROR: [^:]*:\\\n\\\n[^-]*((?=---)|$)")), collapse = "---\n"))
  } else {
    return("")
  }
}, USE.NAMES = FALSE)

combined_warning_log <- sapply(error_df$combined_log, function(log) {
  if (grepl("\\*\\*WARNING", log)) {
    return(paste0(unlist(str_extract_all(log, "\\*\\*WARNING: [^:]*:\\\n\\\n[^-]*((?=---)|$)")), collapse = "---\n"))
  } else {
    return("")
  }
}, USE.NAMES = FALSE)
# Add back to df
error_df <- error_df %>% mutate(
  combined_error_log = combined_error_log,
  combined_warning_log = combined_warning_log
)
# Add counts for errors/warnings
error_df <- error_df %>% mutate(
  errors = grepl("\\*\\*ERROR", combined_log, ignore.case = T),
  warnings = grepl("\\*\\*WARNING", combined_log, ignore.case = T),
  status_label = ifelse(grepl("\\*\\*ERROR", combined_log, ignore.case = T), "ERROR", "DONE")
)
print(error_df)

write.csv(error_df, file = "batch_log.csv", row.names = FALSE)

writeLines(
  paste0(
    "NOTE: See Data/Temp/[Report Folder] for .rmd files for each report.\n",
    "*************************************************************************************\n\n",
    paste0(error_df$combined_log, collapse = "\n=====================================================================================\n=====================================================================================\n\n")
  ),
  "batch.log"
)

# Clean up parallel backend
stopCluster(cl)
