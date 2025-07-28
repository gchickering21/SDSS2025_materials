#------------------------------ Data_Preparation for Each School ------------------------------#
# Get data pieces for each school
i <- 1
school_data_list <- foreach(i = 1:nrow(report_info), .export = exported_functions, .options.snow = opts0) %dopar% {
  run_info <- c()
  report <- report_info$key[i]
  rcdts_key <- report_info$rcdts[i]
  # schools_like_us_rcdts_key <- paste0(rcdts_key)

  result <- list(
    run_info = run_info, rawData_report_parts = NULL,
    school_grade_bands = NULL, staff_survey_respondents = NULL, indicator_ratings = NULL
  )

  tryCatch(
    {
      withCallingHandlers(
        {
          for (pkg in report_packages) {
            suppressPackageStartupMessages(require(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))
          }

          ## Working
          school_grade_bands <- grade_bands %>%
            filter(rcdts == rcdts_key) %>%
            filter(grepl(reportFilter, full_name, ignore.case = TRUE))

          ## Working
          num_principal_surveys <- 4

          ## Working
          num_principa1_interviews <- report_parts %>%
            filter(rcdts == rcdts_key) %>%
            filter(grepl(reportFilter, full_name, ignore.case = TRUE)) %>%
            pull(principal_interview)

          ## Working
          staff_survey_respondents <- 5
          
          ## Workings 
          ind_ratings_school <- ind_ratings %>%
            mutate(rcdts = as.character(rcdts)) %>%
            filter(rcdts == rcdts_key) %>%
            select(-c(school_report))

          rawData_report_parts <- database_school_metrics_combined %>%
            filter(rcdts == rcdts_key) %>%
            relocate(starts_with("IND"), .after = 1) %>%
            select(rcdts, school_and_district_name, contains("IND"), everything()) %>%
            rename(Report = school_and_district_name)
          
          ##Combine in Indicator Ratings from school
          rawData_report_parts <- rawData_report_parts %>%
            left_join(ind_ratings_school, by = "rcdts") %>%
            ungroup()

          #Working
          ##Need to switch over to new file once project team sends over
          school_metrics_school <- school_metrics %>%
            filter(rcdts == rcdts_key)

          result$rawData_report_parts <- rawData_report_parts
          result$school_grade_bands <- school_grade_bands
          result$staff_survey_respondents <- tibble(rcdts = rcdts_key, full_name = report, num_respondents = staff_survey_respondents)
          result$school_metrics_data <- school_metrics_school
          result$indicator_ratings <- ind_ratings_school

          return(result)
        },
        warning = function(w) {
          result$run_info <<- append(result$run_info, paste0("**WARNING: Data Pieces Iteration ", i, " | ", report, " (", rcdts_key, "):\n\n", clean_msg(w)))
          invokeRestart("muffleWarning")
        }
      )
    },
    error = function(e) {
      result$run_info <<- append(result$run_info, paste0("**ERROR: Data Pieces Iteration ", i, " | ", report, " (", rcdts_key, "):\n\n", clean_msg(e)))
    }
  )
  if (is.null(result$rawData_report_parts)) {
    result$rawData_report_parts <- tibble(rcdts = rcdts_key, Report = report, placeholder = NA)
  }
  if (is.null(result$school_grade_bands)) {
    result$school_grade_bands <- tibble(rcdts = rcdts_key, full_name = report, placeholder = NA)
  }
  if (is.null(result$staff_survey_respondents)) {
    result$staff_survey_respondents <- NA
  }
  if (is.null(result$school_metrics_data)) {
    result$school_metrics_data <- NA
  }
  if (is.null(result$indicator_ratings)) {
    result$indicator_ratings <- NA
  }
  return(result)
}

names(school_data_list) <- report_info$key
