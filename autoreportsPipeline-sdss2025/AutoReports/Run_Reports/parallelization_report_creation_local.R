library(dplyr)

run_info <- c()
report <- "Sample School- Sample District"
district <- "Sample District"
rcdts_key <- "12345"
reportData <- reportData  # Already loaded somewhere above

# Get school-level report parts
report_parts_school <- report_parts %>%
  mutate(rcdts = as.character(rcdts)) %>%
  filter(rcdts == rcdts_key) %>%
  slice_head(n = 1)

school <- report_parts_school$school_name_for_report
print('SCHOOL')
print(typeof(school))
print(school)

# Static inputs
staff_survey_resp <- data.frame(
  rcdts = "12345",
  full_name = "Sample School- Sample District",
  num_respondents = 25,
  stringsAsFactors = FALSE
)

# Schools Like Us inputs
culture_climate <- schools_like_us_list[[1]][schools_like_us_list[[1]]$RCDTS == rcdts_key, ]
culture_climate$pHS[is.na(culture_climate$pHS)] <- ""
names(culture_climate)[1] <- "X"

curriculum_instruction <- schools_like_us_list[[2]][schools_like_us_list[[2]]$RCDTS == rcdts_key, ]

leadership_vision <- schools_like_us_list[[3]][schools_like_us_list[[3]]$RCDTS == rcdts_key, ]
leadership_vision$pHS[is.na(leadership_vision$pHS)] <- ""
leadership_vision$p5[is.na(leadership_vision$p5)] <- ""
names(leadership_vision)[1] <- "X"

instruction_support <- schools_like_us_list[[4]][schools_like_us_list[[4]]$RCDTS == rcdts_key, ]

# Static text
static_text <- initial_draft_report

# School metrics
indiv_school_metrics <- school_metrics %>%
  mutate(rcdts = as.character(rcdts)) %>%
  filter(rcdts == rcdts_key) %>%
  slice_head(n = 1)

# Principal survey results
indiv_prin_surv_responses <- principal_survey_counts <- data.frame(
  rcdts = "12345",
  school_and_district_name = "Sample School- Sample District",
  principal_survey_count = 2,
  stringsAsFactors = FALSE
)

# Class observation bullets
class_obs_bullets_school <- class_obs_bullets %>%
  filter(rcdts == "123456")
  

# Run the report

    
# Prepare folder name
folder <- paste0("Output/", rcdts_key)
names(schools_like_us_list) <- gsub("_text\\.csv", "", files)

result <- check_page_version(report_parts_school, rcdts_key)
ind_student_perspec <- result$ind_student_perspec
ind3c_result <- result$ind3c
ind4c_result <- result$ind4c
ind4d_result <- result$ind4d
page21_result <- result$page21
page22_result <- result$page22
page42_result <- result$page42
name_school_district <- "Sample School- Sample District"
reportText <- dynamic_text

output_stem <- paste0("Output/", rcdts_key)
print("about to generate table images")
generate_table_images(report, reportData, reportText, staff_survey_respondents,
                      name_school_district, district, school, report_parts_school, ind_student_perspec,
                      ind3c_result, ind4c_result, ind4d_result, page21_result, page22_result, page42_result,
                      static_text, output_stem)

makeReport(report, reportData, indiv_school_metrics, reportText, staff_survey_resp, indiv_prin_surv_responses,
            name_school_district, district, school, report_parts_school, ind_student_perspec,
            ind3c_result, ind4c_result, ind4d_result, page21_result, page22_result, page42_result,
            static_text, output_stem, culture_climate, curriculum_instruction, leadership_vision,
            instruction_support, class_obs_bullets_school)