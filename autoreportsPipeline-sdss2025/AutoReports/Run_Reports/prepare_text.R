#------------------------------ Prepare Text ------------------------------#
reportText <- prepText(dynamic_text)
reportText$Text <- str_trim(reportText$Text, side = c("left"))

pre_reports <- version_sheet %>%
  filter(v2 %in% c("GENERATING REPORT"))

pre_reports <- pre_reports %>% arrange(key, rcdts)


if (length(reportFilter) > 0 && all(reportFilter != "")) {
  reports <- pre_reports %>%
    filter(grepl(reportFilter, key, ignore.case = TRUE)) %>%
    filter(!grepl(reports_to_skip, key, ignore.case = TRUE)) %>%
    select(rcdts, key)
} else {
  reportFilter <- ""
  reports <- pre_reports %>%
    filter(!grepl(reports_to_skip, key, ignore.case = TRUE)) %>%
    select(rcdts, key)
}

if (nrow(reports) == 0) {
  print_error("\nError: No schools found. Please check report filter.\n")
  stopCluster(cl)
  stop()
}

report_info <- reports %>% mutate(
  school_name = gsub("- .*$", "", key), # Will run into issues if school names have dashes in them
  district_name = gsub("^.*- ", "", key)
)
districts <- table(report_info$district_name)
