cat("--------------------------------------------------------------------------------------------------\n")
cat("--------------------------------------------------------------------------------------------------\n")
print_warning("                                   Starting ILNA Report Run...\n")
cat(paste0("\033[1;95mBatch size:\033[0m\n  ", nrow(report_info), " school", ifelse(nrow(report_info) == 1, "", "s"), " across ", length(districts), " district", ifelse(length(districts) == 1, "", "s"), "\n"))
cat(paste0("\033[1;95mDistricts:\033[0m\n  ", paste0(sapply(1:length(districts), function(i) {
  paste0(names(districts)[i], " - ", districts[i], " report", ifelse(districts[i] == 1, "", "s"))
}), collapse = "\n  "), "\n"))
cat("--------------------------------------------------------------------------------------------------\n")
cat("--------------------------------------------------------------------------------------------------\n")


if (verbose) {
  cat("\n--------------------------------------------------------------------------------------------------\n")
  print_warning("                               Districts in Batch:")
  for (curr_district in unique(report_info$district_name)) {
    subset <- report_info %>% filter(district_name == curr_district)
    cat(paste0("\n\033[1;95m", curr_district, ":\033[0m\n"))
    for (i in 1:nrow(subset)) {
      cat(paste0("  ", subset$school_name[i], "\n"))
    }
  }
  cat("--------------------------------------------------------------------------------------------------\n")
}

start <- Sys.time()
report_packages <- c("readxl", "janitor", "tidyr", "dplyr", "scales", "ggplot2", "stringr", "ggtext", "ggrepel", "rjson", "configr", "RPostgres", "openxlsx", "progress")

print_warning("\n\nGathering data pieces:")

pb0 <- progress_bar$new(
  format = "\r     [:bar] :percent | time elapsed: :elapsed | eta: :eta",
  total = nrow(reports),
  show_after = 0,
  force = TRUE,
  clear = FALSE
)
progress0 <- function(n) {
  pb0$tick()
}
opts0 <- list(progress = progress0)
# Create progress bar before first iteration
invisible(pb0$tick(0))
