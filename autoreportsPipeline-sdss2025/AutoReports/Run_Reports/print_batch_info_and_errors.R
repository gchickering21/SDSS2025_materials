#------------------------------ Print Batch Info and Errors ------------------------------#
# Print batch info and errors encountered
cat("\n\n")
cat("=======================================================\n")
cat("\033[1;32mReport Generation Finished\033[0m\n\n")
cat(paste("The batch took", round(total_time[[1]], 2), units(total_time), "to generate", length(reportList), "reports.\n"))
cat(paste("On average, each report took", round(total_time_secs[[1]] / length(reportList), 2), units(total_time_secs), "to create.\n"))
cat("\n")

if (any(error_df$errors) | any(error_df$warnings)) {
  if (any(error_df$errors)) {
    cat("The following schools encountered errors and did not generate reports,\nPlease check batch.log and the report log files to see their error messages:\n\n")
    for (i in 1:nrow(error_df)) {
      report <- paste0(error_df[i, c("key")], " (", error_df[i, c("rcdts")], ")")
      if (error_df$errors[i]) {
        print_error(paste0(report, "\n"))
      }
    }
  }
  if (any(error_df$warnings & !error_df$errors)) {
    cat("The following reports encountered warnings while still generating reports,\nPlease check batch.log and the report log files to see their warning messages:\n\n")
    for (i in 1:nrow(error_df)) {
      report <- paste0(error_df[i, c("key")], " (", error_df[i, c("rcdts")], ")")
      if (error_df$warnings[i] & !error_df$errors[i]) {
        print_error(paste0(report, "\n"))
      }
    }
  }
} else {
  cat("No errors encountered, all reports have been generated\n")
}

cat("=======================================================\n\n")
