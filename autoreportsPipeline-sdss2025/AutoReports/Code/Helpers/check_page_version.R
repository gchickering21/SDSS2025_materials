check_page_version <- function(report_parts, rcdts) {
  report_parts <- report_parts[grepl(rcdts, report_parts$`rcdts`), ]

  ind_student_perspec <- ""
  ind3c <- ""
  ind4c <- ""
  ind4d <- ""
  page21 <- ""
  page22 <- ""
  page42 <- ""


  ## This will be used for students perspectives logic
  if (report_parts$student_perspective == FALSE) {
    ind_student_perspec <- "empty"
  } else {
    ind_student_perspec <- "full"
  }

  ## This will be used for Indicator 3C logic
  if (report_parts$student_voice_ind3c == FALSE) {
    ind3c <- "empty"
  } else {
    ind3c <- "full"
  }
  ## This will be used for Indicator 4C logic
  if (report_parts$enrichment_ind4c == FALSE) {
    ind4c <- "empty"
  } else {
    ind4c <- "full"
  }

  ## This will be used for Indicator 4D logic
  if (report_parts$college_ind4d == FALSE) {
    ind4d <- "empty"
  } else {
    ind4d <- "full"
  }

  ## This will be used for page21 logic
  if (report_parts$concept_development == TRUE && report_parts$content_understanding == TRUE) {
    page21 <- "concept_dev_content_und"
  } else if (report_parts$concept_development == TRUE && report_parts$content_understanding == FALSE) {
    page21 <- "concept_dev"
  } else {
    page21 <- "content_und"
  }

  ## This will be used for page22 logic
  if (report_parts$language_modeling == TRUE && report_parts$instructional_dialogue == TRUE) {
    page22 <- "language_mod_instructional_dia"
  } else if (report_parts$language_modeling == TRUE && report_parts$instructional_dialogue == FALSE) {
    page22 <- "language_mod"
  } else if (report_parts$language_modeling == FALSE && report_parts$instructional_dialogue == TRUE) {
    page22 <- "instr_dia"
  } else {
    page22 <- "base"
  }

  ## This will be used for page42 logic
  if (report_parts$quality_feedback == TRUE && report_parts$student_engagement == TRUE) {
    page42 <- "qual_feed_stu_eng"
  } else if (report_parts$quality_feedback == TRUE && report_parts$student_engagement == FALSE) {
    page42 <- "qual_feed"
  } else {
    page42 <- "base"
  }

  return(list(ind_student_perspec = ind_student_perspec, ind3c = ind3c, ind4c = ind4c, ind4d = ind4d, page21 = page21, page22 = page22, page42 = page42))
}
