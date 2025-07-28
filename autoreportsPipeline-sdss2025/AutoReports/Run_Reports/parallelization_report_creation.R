#------------------------------ File Creation Loop ------------------------------#
# File creation loop
i <- 1
file_run_info <- lapply(1:length(reportList), function(i) {
  run_info <- c()
  report <- names(reportList)[i]
  school <- report_info$school_name[i] # report_info is same length as reportList
  district <- report_info$district_name[i]
  rcdts_key <- report_info$rcdts[i]
  
  tryCatch(
    {
      # withCallingHandlers is like tryCatch, but will not stop the code - being used to suppress and save warnings
      withCallingHandlers(
        {
          #------------------------------ Prepare Folder Names -------------------------------
          folder <- paste0("Output/", rcdts_key)
          makeFolders(folder)
        },
        warning = function(w) {
          run_info <<- append(run_info, paste0("**WARNING: File Creation Iteration ", i, " | ", report, " (", rcdts_key, "):\n\n", clean_msg(w)))
          invokeRestart("muffleWarning")
        }
      )
    },
    error = function(e) {
      run_info <<- append(run_info, paste0("**ERROR: File Creation Iteration ", i, " | ", report, " (", rcdts_key, "):\n\n", clean_msg(e)))
      # message("Error occurred in iteration ", i, ": ", conditionMessage(e))
    }
  )
  
  return(run_info)
})

names(file_run_info) <- names(reportList)

print_warning("\n\nGenerating Reports:")
pb2 <- progress_bar$new(
  format = "\r     [:bar] :percent | time elapsed: :elapsed | eta: :eta",
  total = length(reportList),
  show_after = 0,
  force = TRUE,
  clear = FALSE
)
progress2 <- function(n) {
  pb2$tick()
}
opts2 <- list(progress = progress2)
# Create progress bar before first iteration
# invisible(pb2$tick(0))

# Parallel foreach loop
i <- 1
report_run <- foreach(i = 1:length(reportList), .export = exported_functions, .options.snow = opts2) %dopar% {
  run_info <- c()
  report <- names(reportList)[i]
  
  district <- report_info$district_name[i]
  rcdts_key <- report_info$rcdts[i]
  reportData <- reportList[[i]]
  report_parts_school <- report_parts %>%
    filter(rcdts == rcdts_key) %>%
    slice_head(n = 1)
  school <- report_parts_school$school_name_for_report # report_info is same length as reportList
  print('SCHOOL')
  print(typeof(school))
  print(school)
  staff_survey_resp <- staff_survey_respondents %>%
    filter(rcdts == rcdts_key)
  
  culture_climate <-  schools_like_us_list[[1]][schools_like_us_list[[1]]$RCDTS == rcdts_key,]
  curriculum_instruction <-  schools_like_us_list[[2]][schools_like_us_list[[2]]$RCDTS == rcdts_key,]
  leadership_vision <-  schools_like_us_list[[3]][schools_like_us_list[[3]]$RCDTS == rcdts_key,]
  instruction_support <-  schools_like_us_list[[4]][schools_like_us_list[[4]]$RCDTS == rcdts_key,]
  
  
  static_text <- initial_draft_report %>% filter(rcdts == rcdts_key) %>% slice_head(n=1)
  
  indiv_school_metrics <- school_metrics %>%
    mutate(rcdts = as.character(rcdts)) %>%
    filter(rcdts == rcdts_key) %>%
    slice_head(n = 1) %>%
    mutate(across(everything(), ~replace_na(.x, "")))
  
  indiv_prin_surv_responses <- principal_survey_counts %>%
    filter(rcdts == rcdts_key)
  
  class_obs_bullets_school <- class_obs_bullets %>%
    filter(rcdts == rcdts_key)
  
  
  tryCatch(
    {
      # withCallingHandlers is like tryCatch, but will not stop the code - being used to suppress and save warnings
      withCallingHandlers(
        {
          # loading packages here instead of in the foreach so we can suppress output from loading
          for (pkg in report_packages) {
            suppressPackageStartupMessages(require(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))
          }
          if (length(data_prep_log[[i]]) != 0 | length(data_backend_log[[i]]) != 0 | length(file_run_info[[i]]) != 0) {
            if (any(grepl("\\*\\*ERROR:", paste0(data_prep_log[[i]], data_backend_log[[i]], file_run_info[[i]])))) {
              return(run_info)
            }
          }
          #------------------------------ Prepare Folder Names -------------------------------#
          folder <- paste0("Output/", rcdts_key)
          # output_file <- file.path(getwd(), folder, paste0(school, ".pdf"))
          
          # new_report_name <- paste0(report_type, "_", foldername, ".docx")
          # #new_report_name <- gsub('City of Chicago SD 299','CPS',new_report_name)
          # new_report <- file.path('Data','Temp',foldername,new_report_name)
          
          
          #------------------------------ PREPARE REPORT VARIABLES -------------------------------#
          ## This will be used to determine which versions of pages we will use for each school
          names(schools_like_us_list) <- gsub("_text\\.csv", "", files)
          result <- check_page_version(report_parts_school, rcdts_key)
          ind_student_perspec <- result$ind_student_perspec
          ind3c_result <- result$ind3c
          ind4c_result <- result$ind4c
          ind4d_result <- result$ind4d
          page21_result <- result$page21
          page22_result <- result$page22
          page42_result <- result$page42
          
          name_school_district <- gsub(" ", "", report)
          
          #------------------------------ Generate Report -------------------------------#
          
          ## TODO: CHECK ON THIS SECTION
          withCallingHandlers(
            {
              output_stem <- paste0("Output/", rcdts_key)
              
              generate_table_images(report, reportData, reportText, staff_survey_respondents,
                                    name_school_district, district, school, report_parts_school,ind_student_perspec,
                                    ind3c_result, ind4c_result, ind4d_result, page21_result, page22_result, page42_result,
                                    static_text, output_stem)
              
              makeReport(report, reportData,  indiv_school_metrics, reportText, staff_survey_resp, indiv_prin_surv_responses,
                         name_school_district, district, school, report_parts_school,ind_student_perspec, 
                         ind3c_result, ind4c_result, ind4d_result, page21_result, page22_result, page42_result,
                         static_text, output_stem, culture_climate, curriculum_instruction, leadership_vision, instruction_support, class_obs_bullets_school)
              
            },
            warning = function(w) {
              if (grepl("Package tagpdf Warning:|\\(tagpdf\\)", conditionMessage(w), ignore.case = T)) {
                invokeRestart("muffleWarning") # hides the tagPDF warning messages that appear - may hide important warnings if changing 508 tagging code
              }
              if (grepl("Vectorized input to `element_text\\(\\)` is not officially supported|Removed [0-9]+ rows containing missing values", conditionMessage(w), ignore.case = T)) {
                invokeRestart("muffleWarning") # hides some expected ggplot warning messages that appear
              }
            }
          )
          
          # TODO: CHECK IF WE NEED ANY OF THIS
          # if(!any(grepl('Error',run_info, ignore.case=T))) {
          #   removeTexOutputFiles(folder, report)
          #   if(!any(grepl('Warning',run_info, ignore.case=T))) {
          #     removeSchoolTempFolder(district)
          #     cleanIntermediates(report)
          #   }
          # }
        },
        warning = function(w) {
          run_info <<- append(run_info, paste0("**WARNING: Report Generation Iteration ", i, " | ", report, " (", rcdts_key, "):\n\n", clean_msg(w)))
          invokeRestart("muffleWarning")
        }
      )
    },
    error = function(e) {
      run_info <<- append(run_info, paste0("**ERROR: Report Generation Iteration ", i, " | ", report, " (", rcdts_key, "):\n\n", clean_msg(e)))
    }
  )
  
  return(run_info)
}

names(report_run) <- names(reportList)

end <- Sys.time()
total_time <- difftime(end, start)
total_time_secs <- difftime(end, start, units = "secs")
