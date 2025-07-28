
# report: Full report name 
# reportData: ind and Plot/Table Data 
# reportText: Class Obs Text 
# staff_survey_respondents: Num Respondents
# name_school_district: Combined District/School name
# district_name: Correct Formatted name 
# school_name: Correct Formatted name

makeReport <- function(report, reportData,indiv_school_metrics, reportText, staff_survey_respondents,indiv_prin_surv_responses, 
                       name_school_district, district, school, report_parts_school,ind_student_perspec, 
                       ind3c_result, ind4c_result, ind4d_result, page21_result, page22_result, page42_result,
                       static_text, temp_stem, culture_climate, curriculum_instruction, leadership_vision, instruction_support,class_obs_bullets_school) {
  
  now <- format(Sys.time(), "%b_%d_%Y_%HHR-%MMIN")
  
  # Replace '/' with '-' in name_school_district
  name_school_district <- gsub("/", "-", name_school_district)
  
  # Construct the file path
  fpath <- paste0("Output/", rcdts_key, "/", name_school_district, "_", now, ".docx")
  output_path <- fpath
  
  final_report <- add_schoolintro(reportData,indiv_school_metrics, staff_survey_respondents,indiv_prin_surv_responses, district, school, static_text, report_parts_school,
                                  temp_stem)
  
  if (TRUE) {
    print('1a')
    
  
    ind <- add_ind1A_schools_like_us(static_text, school, temp_stem, leadership_vision)
    tempFile <- paste0(temp_stem, '/ind1a_schoolsLikeUs.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('1a continued')
    
    
    ind <- add_ind1A_continued(static_text, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind1a_continued.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('1b')
    ind <- add_ind1B(static_text, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind1b.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('1c')
  
    ind <- add_ind1C(static_text, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind1c.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('1d')
  
    ind <- add_ind1D(static_text, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind1d.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
  
    print('2a schools like us')
  
    ind <- add_ind2A_schools_like_us(static_text, ind_student_perspec, school, temp_stem, curriculum_instruction)
    tempFile <- paste0(temp_stem, '/ind2a_schoolsLikeUs.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  if (TRUE) {
    
    print('2a continued')
    
    ind <- add_ind2A_continued(static_text, ind_student_perspec, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind2a_continued.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
  
    print('2b')
  
    ind <- add_ind2B(static_text, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind2b.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }

  if (TRUE) {
    print('2c')
    
    ind <- add_ind2C(reportData, static_text, reportText, ind_student_perspec, report_parts_school, school, temp_stem,class_obs_bullets_school)
    tempFile <- paste0(temp_stem, '/ind2c.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }

  if (TRUE) {
  
    print('2d')
  
    ind <- add_ind2D(static_text, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind2d.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('2e')
  
    ind <- add_ind2E(static_text, ind_student_perspec, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind2e.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
  
    print('3a schoolsLikeUs')
  
    ind <- add_ind3A_schools_like_us(static_text, ind_student_perspec, school, temp_stem, culture_climate)
    tempFile <- paste0(temp_stem, '/ind3a_schoolsLikeUs.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    
    print('3a continued')
    
    ind <- add_ind3A_continued(static_text, ind_student_perspec, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind3a_continued.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('3b')
  
    ind <- add_ind3B(reportData, static_text, reportText, ind_student_perspec, report_parts_school, school, temp_stem,class_obs_bullets_school)
    tempFile <- paste0(temp_stem, '/ind3b.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('3c')
  
    ind <- add_ind3C(static_text, ind_student_perspec, report_parts_school, school, temp_stem,class_obs_bullets_school)
    tempFile <- paste0(temp_stem, '/ind3c.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('3d')
  
    ind <- add_ind3D(static_text, ind_student_perspec, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind3d.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('3e')
  
    ind <- add_ind3E(static_text, ind_student_perspec, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind3e.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('4a schoolslikeUS')
  
    ind <- add_ind4A_schools_like_us(static_text, ind_student_perspec, school, temp_stem, instruction_support)
    tempFile <- paste0(temp_stem, '/ind4a_schoolsLikeUs.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('4a')
    
    ind <- add_ind4A_continued(static_text, ind_student_perspec, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind4a_continued.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('4b')

    ind <- add_ind4B(reportData, static_text, reportText, ind_student_perspec, report_parts_school, school, temp_stem,class_obs_bullets_school)
    tempFile <- paste0(temp_stem, '/ind4b.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('4c')
  
    ind <- add_ind4C(static_text, ind_student_perspec, report_parts_school, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind4c.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  if (TRUE) {
    print('4d')
  
    ind <- add_ind4D(static_text, ind_student_perspec, report_parts_school, school, temp_stem)
    tempFile <- paste0(temp_stem, '/ind4d.docx')
    print(ind, target = tempFile)
    final_report <- add_ind(final_report, tempFile)
  }
  
  print(final_report, target=fpath)
}

# Helpers
add_ind <- function(doc, add_path) {

  # portrait = officer::block_section(
  #   officer::prop_section(
  #     page_size = page_size(orient="portrait"), 
  #     type = 'nextPage'
  #   )
  # )
  doc <- officer::cursor_end(doc) %>% officer::body_end_section_portrait() %>% officer::body_add_docx(add_path, pos = "after")
  # doc <- officer::cursor_end(doc) %>% officer::body_end_block_section(value=portrait) %>% officer::body_add_docx(add_path, pos = "after")
  
  return(doc)
}

add_page<- function(doc, add_path) {
  
  doc <- officer::cursor_end(doc) %>% officer::body_add_docx(add_path, pos = "after")
  
  return(doc)
}

add_schools_like_us <- function(doc, slu) {
  p1 <- as.character(slu$p1)
  p2 <- as.character(slu$p2)
  p3 <- as.character(slu$p3)
  p4 <- as.character(slu$p4)
  p5 <- as.character(slu$p5)
  p6 <- as.character(slu$p6)
  pHS <- as.character(slu$pHS)
  closing_p <- as.character(slu$closing_p)
  ft_1 <- as.character(slu$footnote.1_text)
  ft_2 <- as.character(slu$footnote.2_text)
  
  #p1
  if(!is.na(p1) & p1 != ""){
    p1 <- gsub("/par", "", p1)
    superscript <- officer::fp_text(font.family = "Calibri (Body)", font.size = 8, bold = FALSE, vertical.align = 'superscript')
    regular_fp <- officer::fp_text(font.family = "Calibri (Body)", font.size = 10, bold = FALSE)
    
    doc <- officer::cursor_reach(doc, 'p1')
    doc <-officer::body_replace_all_text(doc, 'p1', '')
    
    if(grepl("<footnote 1_num>", p1) & grepl("<footnote ,>", p1) & grepl("<footnote 2_num>", p1)){
      p1_split <- strsplit(p1, split = "<footnote 1_num><footnote ,><footnote 2_num>")[[1]]
      print(p1_split)
      p1_1 <- p1_split[1]
      
      if(length(p1_split)>1){
        p1_2 <- p1_split[2]
        
        p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
        superscript_1 <- officer::ftext('1,2', prop = superscript)
        p1_2_text <- officer::ftext(p1_2, prop = regular_fp)
        
        p1_final <- officer::fpar(p1_1_text, superscript_1, p1_2_text)
        
      } else {
        p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
        superscript_1 <- officer::ftext('1,2', prop = superscript)
        
        p1_final <- officer::fpar(p1_1_text, superscript_1)
      }
      
      doc <- officer::body_add_fpar(doc, p1_final, pos ='on')
      
    } else if(grepl("<footnote 1_num>", p1) & grepl("<footnote 2_num>", p1)){
      p1_split <- strsplit(p1, split = "<footnote 1_num>")[[1]]
      p1_1 <- p1_split[1]
      p1_split <- p1_split[2]
      p1_split <- strsplit(p1_split, split = "<footnote 2_num>")[[1]]
      p1_2 <- p1_split[1]

      if(length(p1_split)>1){
        p1_3 <- p1_split[2]
        
        p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
        superscript_1 <- officer::ftext('1', prop = superscript)
        p1_2_text <- officer::ftext(p1_2, prop = regular_fp)
        superscript_2 <- officer::ftext('2', prop = superscript)
        p1_3_text <- officer::ftext(p1_3, prop = regular_fp)
        
        p1_final <- officer::fpar(p1_1_text, superscript_1, p1_2_text,
                                  superscript_2, p1_3_text)

      } else {
        p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
        superscript_1 <- officer::ftext('1', prop = superscript)
        p1_2_text <- officer::ftext(p1_2, prop = regular_fp)
        superscript_2 <- officer::ftext('2', prop = superscript)
        
        p1_final <- officer::fpar(p1_1_text, superscript_1,
                                  p1_2_text, superscript_2)
      }
      
      doc <- officer::body_add_fpar(doc, p1_final, pos ='on') 
      
    } else if (grepl("<footnote 1_num>", p1)){
      p1_split <- strsplit(p1, split = "<footnote 1_num>")[[1]]
      p1_1 <- p1_split[1]
      
      if(length(p1_split)>1){
        p1_2 <- p1_split[2]
        
        p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
        superscript_1 <- officer::ftext('1', prop = superscript)
        p1_2_text <- officer::ftext(p1_2, prop = regular_fp)
        
        p1_final <- officer::fpar(p1_1_text, superscript_1, p1_2_text)
        
      } else {
        p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
        superscript_1 <- officer::ftext('1', prop = superscript)
        
        p1_final <- officer::fpar(p1_1_text, superscript_1)
      }
      
      doc <- officer::body_add_fpar(doc, p1_final, pos ='on')
      
    } else if (grepl("<footnote 2_num>", p1)){
        p1_split <- strsplit(p1, split = "<footnote 2_num>")[[1]]
        p1_1 <- p1_split[1]
        
        if(length(p1_split)>1){
          p1_2 <- p1_split[2]
          
          p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
          superscript_2 <- officer::ftext('2', prop = superscript)
          p1_2_text <- officer::ftext(p1_2, prop = regular_fp)
          
          p1_final <- officer::fpar(p1_1_text, superscript_2, p1_2_text)
          
        } else {
          p1_1_text <- officer::ftext(p1_1, prop = regular_fp)
          superscript_2 <- officer::ftext('2', prop = superscript)
          p1_final <- officer::fpar(p1_1_text, superscript_2)
        }
        
        doc <- officer::body_add_fpar(doc, p1_final, pos ='on')
        
    } else {
      doc <- officer::body_add_par(doc, 'p1', pos = 'on')
    }
    
    
    # doc <- officer::body_replace_all_text(doc, 'p1', p1)
  }else{
    doc <- officer::cursor_reach(doc, 'p1')
    doc <- officer::body_remove(doc)
  }

  #p2
  if(!is.na(p2) & p2 != ""){
    doc <- add_slu_bullet_par(doc, p2, 'p2')
  }else{
    doc <- officer::cursor_reach(doc, 'p2')
    doc <- officer::body_remove(doc)
  }
  
  #p3
  if(!is.na(p3) & p3 != ""){
    doc <- add_slu_bullet_par(doc, p3, 'p3')
  }else{
    doc <- officer::cursor_reach(doc, 'p3')
    doc <- officer::body_remove(doc)
  }
  
  #p4
  if(!is.na(p4) & p4 != ""){
    doc <- add_slu_bullet_par(doc, p4, 'p4')
  }else{
    doc <- officer::cursor_reach(doc, 'p4')
    doc <- officer::body_remove(doc)
  }
  
  #p5
  if(!is.na(p5) & p5 != ""){
    doc <- add_slu_bullet_par(doc, p5, 'p5')
  }else{
    doc <- officer::cursor_reach(doc, 'p5')
    doc <- officer::body_remove(doc)
  }
  
  #p6
  if(!is.na(p6) & p6 != ""){
    doc <- add_slu_bullet_par(doc, p6, 'p6')
  }else{
    doc <- officer::cursor_reach(doc, 'p6')
    doc <- officer::body_remove(doc)
  }
  
  #pHS
  if(!is.na(pHS) & pHS != ""){
    doc <- add_slu_bullet_par(doc, pHS, 'pHS')
  }else{
    doc <- officer::cursor_reach(doc, 'pHS')
    doc <- officer::body_remove(doc)
  }
  
  #closing
  if(!is.na(closing_p) & closing_p != ""){
    closing_p <- gsub("\\\\", "", closing_p)
    doc <- officer::body_replace_all_text(doc, 'closing_p', closing_p)
  }else{
    doc <- officer::cursor_reach(doc, 'closing_p')
    doc <- officer::body_remove(doc)
  }
  
  #ft_1
  if(!is.na(ft_1) & ft_1 != ""){
    ft_1 <- gsub('<footnote 1_text>', "", ft_1)
    ft_1 <- gsub('</footnote_text>', "", ft_1)
    
    doc <- officer::cursor_reach(doc, 'ft_1')
    doc <- officer::body_replace_all_text(doc, 'ft_1', "")
    
    superscript <- officer::fp_text(font.family = "Calibri (Body)", font.size = 8, bold = FALSE, vertical.align = 'superscript')
    footnote_fp <- officer::fp_text(font.family = "Calibri (Body)", font.size = 9, bold = FALSE)
    
    superscript_1 <- officer::ftext('1', prop = superscript)
    footnote_1 <- officer::ftext(ft_1, prop = footnote_fp)
    
    footnote_text_1 <- officer::fpar(superscript_1, footnote_1)
    
    doc <- officer::body_add_fpar(doc, footnote_text_1, pos = 'on')
  }else{
    doc <- officer::cursor_reach(doc, 'ft_1')
    doc <- officer::body_remove(doc)
  }
  
  #ft_2
  if(!is.na(ft_2) & ft_2 != ""){
    ft_2 <- gsub('<footnote 2_text>', "", ft_2)
    ft_2 <- gsub('</footnote_text>', "", ft_2)
    
    doc <- officer::cursor_reach(doc, 'ft_2')
    doc <- officer::body_replace_all_text(doc, 'ft_2', "")
    
    superscript <- officer::fp_text(font.family = "Calibri (Body)", font.size = 8, bold = FALSE, vertical.align = 'superscript')
    footnote_fp <- officer::fp_text(font.family = "Calibri (Body)", font.size = 9, bold = FALSE)
    
    superscript_2 <- officer::ftext('2', prop = superscript)
    footnote_2 <- officer::ftext(ft_2, prop = footnote_fp)
    
    footnote_text_2 <- officer::fpar(superscript_2, footnote_2)
    
    doc <- officer::body_add_fpar(doc, footnote_text_2, pos = 'on')
  }else{
    doc <- officer::cursor_reach(doc, 'ft_2')
    doc <- officer::body_remove(doc)
  }
  
  # doc <- officer::body_replace_all_text(doc, 'schoolsLikeUs', slu[['Full.Text']])
  return(doc)
}

add_slu_bullet_par <- function(doc, paragraph, target) {
  
  parts <- strsplit(paragraph, split = "<bullet>")
  head <- parts[[1]][1]
  head <- gsub("\\\\", "", head)
  head <- gsub("<list>", "", head)
  bullets <- parts[[1]][2:length(parts[[1]])]
  bullets <- gsub("</list>", "", bullets)
  
  doc <- officer::cursor_reach(doc, target)
  doc <- officer::body_add_par(doc, head, style = 'Body Text', pos = 'before')
  doc <- add_bullets(doc, target, bullets)
  for(i in bullets){
    doc <- officer::cursor_forward(doc)
  }
  doc <- officer::body_remove(doc)
  return(doc)
}

add_rating_table <- function(doc, image) {
  doc <- officer::cursor_reach(doc, "ratingTable")
  doc <- officer::body_replace_all_text(doc, "ratingTable", "")
  doc <- officer::body_add_img(doc, image, pos = "on", width = 7.3, height = .61)
  
  return(doc)
}

add_intro_text <- function(doc, text) {
  doc <- officer::body_replace_all_text(doc, "introText", text)
  return(doc)
}

add_overall_text <- function(doc, text) {
  doc <- officer::body_replace_all_text(doc, "overallText", text)
  return(doc)
}

add_5e <- function(doc, table, plot, height) {
  # Validate image file paths
  print(table)
  print(plot)
  if (!file.exists(table)) stop(paste("❌ 5E table image not found:", table))
  if (!file.exists(plot)) stop(paste("❌ 5E plot image not found:", plot))

  doc <- officer::body_replace_img_at_bkm(doc, 'img5e', officer::external_img(table, width = 5.36, height = height))
  doc <- officer::body_replace_img_at_bkm(doc, 'plot5e', officer::external_img(plot, width = 1.81, height = 3.08))

  return(doc)
}


add_staff_survey_response <- function(doc, image, staff_survey_text = "staffSurvey", height) {
  doc <- officer::cursor_reach(doc, staff_survey_text)
  doc <- officer::body_replace_all_text(doc, staff_survey_text, "")
  doc <- officer::body_add_img(doc, image, pos = "on", width = 7, height = height)
  
  return(doc)
}


add_bullets <- function(doc, target, bullets) { 
  # Remove "NaN" and reverse bullets
  bullets <- bullets[bullets != "NaN" & nzchar(bullets)]
  bullets <- rev(bullets)  # Reverse the order
  doc <- officer::cursor_reach(doc, target)
  doc <- officer::body_replace_all_text(doc, target, "")
  if(target == 'studentPerspective'){
    doc <- officer::body_add_par(doc, 'STUDENT PERSPECTIVES:', style='Heading 4 No TOC', pos = 'on')
    for (i in rev(bullets)){
      if(is.character(i)){
        doc <- officer::body_add_par(doc, i, style='Bullet 1', pos = 'after')
      }
    }
  } else {
    for (i in bullets){
      if(is.character(i)){
        doc <- officer::body_add_par(doc, i, style='Bullet 1', pos = 'before')
      }
    }
  }
  

  return(doc)
}

add_class_obs <- function(doc, reportData, reportText, static_text, classObs_type, report_indicator_type, tbl_number, separate_intro = FALSE, temp_stem, class_obs_bullets_school,dimension_number, special_class_obs = FALSE) {
  
  # Determine observation count, rating, and grade band
  class_obs_count <- determine_obs_count(reportData, tbl_number)
  class_obs_rating <- determine_class_observation_ratings(reportData, tbl_number)[class_obs_count]
  class_obs_grade_band <- reportData[[tbl_number]]$Variable[class_obs_count]
  
  row_count <- nrow(reportData[[tbl_number]])
  if (special_class_obs) {
    if (report_indicator_type == "ConceptDevelopment") {
      if (class_obs_count > 1) {
        report_indicator_type <- "ContentUnderstanding"
      }
    } else if (report_indicator_type == "LanguageModeling") {
      if (class_obs_count > 1) {
        report_indicator_type <- "InstructionalDialogue"
      }
    }
  }
  
  
  # Generate the introductory and base text
  report_indicator_text_intro <- report_indicator_text_intro(
    text_file = reportText, 
    report_indicator = report_indicator_type, 
    rating = class_obs_rating, 
    grade_type = class_obs_grade_band, 
    separate_intro = separate_intro
  )
  
  report_indicator_text_base <- report_indicator_text(
    text_file = reportText, 
    report_indicator = report_indicator_type, 
    rating = class_obs_rating
  )
  
  # Combine intro and base text
  class_obs_text_school <- paste(report_indicator_text_intro, report_indicator_text_base)
  
  # Define words to bold
  bold_words <- c("low", "middle", "high")
  
  # Define text formatting properties
  regular_fp <- officer::fp_text(font.family = "Calibri (Body)", font.size = 10, bold = FALSE)
  bold_fp <- officer::fp_text(font.family = "Calibri (Body)", font.size = 10, bold = TRUE)
  
  # Split text into words while maintaining spacing
  words <- unlist(strsplit(class_obs_text_school, "(?<=\\s)|(?=\\s)", perl = TRUE))
  
  # Flag to track if any bold word has been found
  bold_word_found <- FALSE  
  
  # Apply conditional formatting
  formatted_parts <- lapply(words, function(word) {
    trimmed_word <- gsub("^\\s+|\\s+$", "", word)  # Remove leading/trailing spaces
    
    if (!bold_word_found && trimmed_word %in% bold_words) {
      bold_word_found <<- TRUE  # Set flag to TRUE after first bold word
      officer::ftext(word, bold_fp)
    } else {
      officer::ftext(word, regular_fp)
    }
  })
  
  # Combine formatted text into a paragraph with 1.15 spacing
  formatted_text <- do.call(officer::fpar, c(formatted_parts, list(fp_p = officer::fp_par(line_spacing = 1.15))))
  
  # Move the cursor to the placeholder text
  doc <- officer::cursor_reach(doc, keyword = paste0("classObs", classObs_type, "Text"))
  
  # # Remove the placeholder text
  doc <- officer::body_replace_all_text(doc, paste0("classObs", classObs_type, "Text"), "")
  
  # **Add the formatted text before the table**
  doc <- officer::body_add_fpar(doc, formatted_text, pos = "on")
  
  # Construct the table path
  table_path <- file.path(temp_stem, "Temp", "Tables", paste0("CO_", classObs_type, ".png"))
  
  # Move to table placeholder and replace with an image
  doc <- officer::cursor_reach(doc, paste0("classObs", classObs_type, "Table"))
  doc <- officer::body_add_img(doc, table_path, width = 7.3, height = (0.52 + (row_count * 0.21)), pos = "after")
  doc <- officer::body_replace_all_text(doc, paste0("classObs", classObs_type, "Table"), "")
  

  class_bullets_text <- class_obs_bullets_school %>%
    filter(dimension_id == dimension_number) %>%
    arrange(indication_sort_order) %>%
    pull(observation_reconciliation)  # Extract as a character vector

  doc <- add_bullets(doc, paste0("classObs", classObs_type, "Bullets"), class_bullets_text)
  return(doc)
}

# Indicators

add_schoolintro <- function(reportData, indiv_school_metrics, staff_survey_respondents,indiv_prin_surv_responses, district, school, static_text, report_parts_school,temp_stem) {
  doc <- officer::read_docx("Templates/school_intro_full.docx")
  # PAGE 1
  doc <- officer::body_replace_all_text(doc, "schoolName", school)
  doc <- officer::body_replace_all_text(doc, "districtName", district)
  doc <- officer::body_replace_all_text(doc, 'monthTime', paste(format(Sys.Date(), "%B %Y")))
  
  # PAGE 2-5
  # doc2 <- officer::read_docx("Templates/school_intro_2.docx")

  # doc <- officer::body_replace_all_text(doc, "schoolName", school)
  doc <- officer::body_replace_all_text(doc, "districtName", district)
  doc <- officer::body_replace_all_text(doc, 'teacherCount', as.character(round(as.numeric(indiv_school_metrics$teacher_count), 0)))
  doc <- officer::body_replace_all_text(doc, 'studentCount', as.character(indiv_school_metrics$x_student_enrollment))
  doc <- officer::body_replace_all_text(doc, 'gradesServed', as.character(indiv_school_metrics$grades_served))
  doc <- officer::body_replace_all_text(doc, 'studWDis', as.character(indiv_school_metrics$x_student_enrollment_children_with_disabilities))
  doc <- officer::body_replace_all_text(doc, 'studLowIncome', as.character(indiv_school_metrics$x_student_enrollment_low_income))
  needLevel <- ifelse(report_parts_school$tier == "ISI" ,'intensive', 'comprehensive')
  doc <- officer::body_replace_all_text(doc, 'needLevel', as.character(needLevel))
  
  
  doc <- officer::cursor_reach(doc, "summaryStrengths")
  strength <- c(static_text$strengths1, static_text$strengths2, static_text$strengths3, static_text$strengths4, static_text$strengths5, static_text$strengths6)
  doc <- add_bullets(doc, 'summaryStrengths', strength)
  
  doc <- officer::footers_replace_all_text(doc, "schoolName", school)
  
  # tempFile2 <- paste0(temp_stem, '/school_intro_2.docx')
  # print(doc2, target = tempFile2)
  # doc <- add_ind(doc, tempFile2)
  
  # PAGE 6
  # doc3 <- officer::read_docx("Templates/school_intro_3.docx")
  
  doc <- officer::cursor_reach(doc, "areasGrowth")
  growth <- c(static_text$growth_areas1, static_text$growth_areas2, static_text$growth_areas3, static_text$growth_areas4, static_text$growth_areas5)
  doc <- add_bullets(doc, 'areasGrowth', growth)
  
  # doc3 <- officer::body_replace_all_text(doc3, "schoolName", school)
  
  if(report_parts_school$principal_interview > 1){
    prin_int <- " principal interviews "
  } else {
    prin_int <- " principal interview "
  }
  prin_int_text <- paste0(as.character(report_parts_school$principal_interview), prin_int)
  doc <- officer::body_replace_all_text(doc, 'prinInterview', prin_int_text)
  
  
  # #NEED TO GET WHERE THIS COMES FROM
  num_principal_surveys <- indiv_prin_surv_responses$principal_survey_count
  if(num_principal_surveys > 1){
    prin_sur <- "survey responses"
  } else {
    prin_sur <- "survey response"
  }
  prin_sur_text <- paste(as.character(num_principal_surveys), prin_sur)
  doc <- officer::body_replace_all_text(doc, 'prinSurveyResponse',prin_sur_text)
  
  staff_survey_num <- as.character(staff_survey_respondents$num_respondents)
  doc <- officer::body_replace_all_text(doc, 'surveyResp', staff_survey_num)
  
  # #GET VARIABLES WHEN THEY ARE PROVIDED
  doc <- officer::body_replace_all_text(doc, '5eStudRespRate', as.character(indiv_school_metrics$student_response_rate_24))
  doc <- officer::body_replace_all_text(doc, '5eTeachRespRate', as.character(indiv_school_metrics$teacher_response_rate_24))

  # doc3 <- officer::footers_replace_all_text(doc3, "schoolName", school)
  
  if(ind_student_perspec == 'full'){
    doc <- officer::body_replace_all_text(doc, "studentfocusgroup", "")
  }else{
    doc <- officer::cursor_reach(doc, "studentfocusgroup")
    doc <- officer::body_remove(doc)
  }
  
  # tempFile3 <- paste0(temp_stem, '/school_intro_3.docx')
  # print(doc3, target = tempFile3)
  # doc <- add_ind(doc, tempFile3)
  
  # PAGE 7
  # doc4 <- officer::read_docx("Templates/school_intro_4.docx")
  
  # doc4 <- officer::body_replace_all_text(doc4, "schoolName", school)
  doc <- officer::cursor_reach(doc, "indTable")
  doc <- officer::body_replace_all_text(doc, "indTable", "")
  introRatingPath <- paste0(temp_stem, "/Temp/Tables/introRatingTable.png")
  print(paste("🔍 Looking for introRatingPath image:", introRatingPath))
  if (!file.exists(introRatingPath)) stop(paste("❌ introRatingTable.png not found at:", introRatingPath))

  doc <- officer::body_add_img(doc, introRatingPath, width = 7.2, height = 7, pos="on")
  
  # doc4 <- officer::footers_replace_all_text(doc4, "schoolName", school)
  
  # tempFile4 <- paste0(temp_stem, '/school_intro_4.docx')
  # print(doc4, target = tempFile4)
  # doc <- add_ind(doc, tempFile4)
  tempFile <- paste0(temp_stem, '/school_intro.docx')
  print(doc, tempFile)

  doc2 <- officer::read_docx(tempFile)
  return(doc2)
}

add_ind1A_schools_like_us <- function(static_text, school, temp_stem, slu_text) {
  doc <- officer::read_docx("Templates/ind1A_schoolsLikeUs.docx")
  doc <- add_schools_like_us(doc, slu_text)
  
  # doc <- officer::cursor_reach(doc, 'schoolsLikeUs') %>% officer::body_end_section_portrait()
  
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  return(doc)
}

add_ind1A_continued <- function(static_text, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind1A_continued.docx")
  
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind1a_rating
  doc <- add_intro_text(doc, introText)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
      header <- paste0(temp_stem, "/Temp/Tables/ind1A_header.png")
    doc <- add_rating_table(doc, header)}
  

  overallText <- static_text$ind1a_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl1a.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl1a.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.47)
  
  
  fig1a <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1a.png")
  doc <- add_staff_survey_response(doc, fig1a, height = 2.2)

  bullets <- c(static_text$ind1a_staff_perspective1, static_text$ind1a_staff_perspective2, static_text$ind1a_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  

  return(doc)
}

add_ind1B <- function(static_text, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind1B.docx")
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind1B_header.png")
    doc <- add_rating_table(doc, header)}
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind1b_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind1b_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl1b.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl1b.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.17)

  fig1b <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1b.png")
  doc <- add_staff_survey_response(doc, fig1b, height = 3.66)
  
  bullets <- c(static_text$ind1b_staff_perspective1, static_text$ind1b_staff_perspective2, static_text$ind1b_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  return(doc)
}

add_ind1C <- function(static_text, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind1C.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind1C_header.png")
    doc <- add_rating_table(doc, header)}
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind1c_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind1c_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl1c.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl1c.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.17)
  
  fig1c_1 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1c.1.png")
  doc <- add_staff_survey_response(doc, fig1c_1, staff_survey_text = "staffSurvey", height = 1.74)
  fig1c_2 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1c.2.png")
  doc <- add_staff_survey_response(doc, fig1c_2, staff_survey_text = "surveyStaff", height = 1.01)

  bullets <- c(static_text$ind1c_staff_perspective1, static_text$ind1c_staff_perspective2, static_text$ind1c_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)

  return(doc)
}

add_ind1D <- function(static_text, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind1D.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind1D_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind1d_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind1d_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl1d.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl1d.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.17)
  
  fig1d_1 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1d.1.png")
  doc <- add_staff_survey_response(doc, fig1d_1, staff_survey_text = "staffSurvey", height = 2.56)
  fig1d_2 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1d.2.png")
  doc <- add_staff_survey_response(doc, fig1d_2, staff_survey_text = "surveyStaff", height = 1.01)
  # fig1d_3 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig1d.3.png")
  # doc <- add_staff_survey_response(doc, fig1d_3, staff_survey_text = "surSta", height = 1.37)
  
  bullets <- c(static_text$ind1d_staff_perspective1, static_text$ind1d_staff_perspective2, static_text$ind1d_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)

  return(doc)
}

add_ind2A_schools_like_us <- function(static_text, ind_student_perspec, school, temp_stem, slu_text) {
  doc <- officer::read_docx("Templates/ind2A_schoolsLikeUs.docx")

  doc <- add_schools_like_us(doc, slu_text)
  
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  return(doc)
}

add_ind2A_continued <- function(static_text, ind_student_perspec, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind2A_continued.docx")
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind2A_header.png")
    doc <- add_rating_table(doc, header)}
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind2a_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind2a_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig2a <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2a.png")
  doc <- add_staff_survey_response(doc, fig2a, height = 3.66)

  bullets <- c(static_text$ind2a_staff_perspective1, static_text$ind2a_staff_perspective2, static_text$ind2a_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    # doc <- officer::cursor_reach(doc, 'headerPgBreak')
    # doc <- officer::body_add_par(doc, "INDICATOR 2.A: HIGH-QUALITY, DEFINED CURRICULUM (CONT.)", style='Heading 3 No TOC', pos = 'before')
    # doc <- officer::body_add_break(doc, pos = 'before')
    # doc <- officer::cursor_reach(doc, 'headerPgBreak')
    # doc <- officer::body_remove(doc)
    
    
    bullets <- c(static_text$ind2a_student_perspective1, static_text$ind2a_student_perspective2, static_text$ind2a_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind2B <- function(static_text,school, temp_stem) {
  print("CCC 1")
  print(getwd())
  doc <- officer::read_docx("Templates/ind2B.docx")
  print("CCC 2")
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  print("CCC 3")
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind2B_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind2b_rating
  doc <- add_intro_text(doc, introText)
  print("CCC 4")
  overallText <- static_text$ind2b_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl2b.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl2b.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.17)
  
  fig2b_1 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2b.1.png")
  doc <- add_staff_survey_response(doc, fig2b_1, staff_survey_text = "staffSurvey", height = 3.43)
  fig2b_2 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2b.2.png")
  doc <- add_staff_survey_response(doc, fig2b_2, staff_survey_text = "surveysStaff", height = 1.01)

  bullets <- list(static_text$ind2b_staff_perspective1, static_text$ind2b_staff_perspective2, static_text$ind2b_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)

  return(doc)
}

add_ind2C <- function(reportData, static_text, reportText, ind_student_perspec, report_parts_school, school, temp_stem, class_obs_bullets_school) {
  print("here 1")
  if (report_parts_school$concept_development == TRUE && report_parts_school$content_understanding == TRUE) {
    doc <- officer::read_docx("Templates/ind2C_CUCD.docx")
    doc <- add_class_obs(doc,reportData, reportText, static_text,"CUCD", "ConceptDevelopment", "tbl2c.1",separate_intro = FALSE, temp_stem, class_obs_bullets_school,8, special_class_obs = TRUE)
    doc <- add_class_obs(doc,reportData, reportText, static_text,"LMID", "LanguageModeling", "tbl2c.3", separate_intro = FALSE, temp_stem,class_obs_bullets_school,10, special_class_obs = TRUE)
    doc <- add_class_obs(doc,reportData, reportText, static_text,"AI", "AnalysisInquiry", "tbl2c.2",separate_intro = FALSE, temp_stem, class_obs_bullets_school,11,special_class_obs = FALSE)
  } else if (report_parts_school$concept_development == TRUE) {
    doc <- officer::read_docx("Templates/ind2C_CD.docx")
    doc <- add_class_obs(doc,reportData,  reportText,static_text, "CUCD", "ConceptDevelopment","tbl2c.1",separate_intro = FALSE,temp_stem, class_obs_bullets_school,8, special_class_obs = FALSE)
    doc <- add_class_obs(doc,reportData, reportText, static_text,"LMID", "LanguageModeling", "tbl2c.3",separate_intro = FALSE, temp_stem, class_obs_bullets_school,10, special_class_obs = FALSE)
  } else {
    doc <- officer::read_docx("Templates/ind2C_CU.docx")
    doc <- add_class_obs(doc,reportData, reportText, static_text, "CUCD","ContentUnderstanding","tbl2c.1", separate_intro = FALSE,temp_stem, class_obs_bullets_school,8, special_class_obs = FALSE)
    doc <- add_class_obs(doc,reportData, reportText, static_text,"LMID", "InstructionalDialogue", "tbl2c.3",separate_intro = FALSE, temp_stem,class_obs_bullets_school,10, special_class_obs = FALSE)
    doc <- add_class_obs(doc,reportData, reportText, static_text,"AI", "AnalysisInquiry", "tbl2c.2",separate_intro = FALSE, temp_stem, class_obs_bullets_school,11, special_class_obs = FALSE)
  }
  print("here 2")
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind2C_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind2c_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind2c_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig2c <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2c.png")
  doc <- add_staff_survey_response(doc, fig2c, height = 3.02)

  bullets <- list(static_text$ind2c_staff_perspective1, static_text$ind2c_staff_perspective2, static_text$ind2c_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind2c_student_perspective1, static_text$ind2c_student_perspective2, static_text$ind2c_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind2D <- function(static_text, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind2D.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind2D_header.png")
    doc <- add_rating_table(doc, header)}
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind2d_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind2d_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig2d <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2d.png")
  doc <- add_staff_survey_response(doc, fig2d, height = 3.02)
  
  bullets <- list(static_text$ind2d_staff_perspective1, static_text$ind2d_staff_perspective2, static_text$ind2d_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)

  return(doc)
}

add_ind2E <- function(static_text, ind_student_perspec, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind2E.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind2E_header.png")
    doc <- add_rating_table(doc, header)}
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind2e_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind2e_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig2e_1 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2e.1.png")
  doc <- add_staff_survey_response(doc, fig2e_1, staff_survey_text = "staffSurvey", 1.74)
  fig2e_2 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig2e.2.png")
  doc <- add_staff_survey_response(doc, fig2e_2, staff_survey_text = "surveyStaff", 1.37)

  bullets <- list(static_text$ind2e_staff_perspective1, static_text$ind2e_staff_perspective2, static_text$ind2e_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind2e_student_perspective1, static_text$ind2e_student_perspective2, static_text$ind2e_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }
  
  return(doc)
}

add_ind3A_schools_like_us <- function(static_text, ind_student_perspec, school, temp_stem, slu_text) {
  doc <- officer::read_docx("Templates/ind3A_schoolsLikeUs.docx")
  doc <- add_schools_like_us(doc, slu_text)
  
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)

  
  return(doc)
}

add_ind3A_continued <- function(static_text, ind_student_perspec, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind3A_continued.docx")
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind3A_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind3a_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind3a_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl3a.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl3a.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.17)
  
  fig3a <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig3a.png")
  doc <- add_staff_survey_response(doc, fig3a, height = 3.43)

  bullets <- list(static_text$ind3a_staff_perspective1, static_text$ind3a_staff_perspective2, static_text$ind3a_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind3a_student_perspective1, static_text$ind3a_student_perspective2, static_text$ind3a_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind3B <- function(reportData, static_text, reportText, ind_student_perspec, report_parts_school, school, temp_stem,class_obs_bullets_school) {
  doc <- officer::read_docx("Templates/ind3B.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind3B_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind3b_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind3b_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  doc <- add_class_obs(doc,reportData, reportText, static_text,"PC", "PositiveClimate", "tbl3b.1", separate_intro = TRUE,temp_stem, class_obs_bullets_school,1, special_class_obs = FALSE)
  doc <- add_class_obs(doc,reportData, reportText, static_text,"TS", "TeacherSensitivity", "tbl3b.2",separate_intro = TRUE, temp_stem, class_obs_bullets_school,3, special_class_obs = FALSE)
  doc <- add_class_obs(doc,reportData, reportText, static_text,"BM", "BehaviorManagement", "tbl3b.3",separate_intro =  TRUE, temp_stem, class_obs_bullets_school,5, special_class_obs = FALSE)
  doc <- add_class_obs(doc,reportData, reportText, static_text,"PD", "Productivity", "tbl3b.4",separate_intro = TRUE, temp_stem, class_obs_bullets_school,6, special_class_obs = FALSE)
  doc <- add_class_obs(doc,reportData, reportText, static_text,"NC", "NegativeClimate", "tbl3b.5",separate_intro = TRUE, temp_stem, class_obs_bullets_school,2, special_class_obs = FALSE)
  
  fig3b <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig3b.png")
  doc <- add_staff_survey_response(doc, fig3b, height = 3.02)
  
  bullets <- c(static_text$ind3b_staff_perspective1, static_text$ind3b_staff_perspective2, static_text$ind3b_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)

  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind3b_student_perspective1, static_text$ind3b_student_perspective2, static_text$ind3b_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }
  
  return(doc)
}

add_ind3C <- function(static_text, ind_student_perspec, report_parts_school, school, temp_stem, class_obs_bullets_school) {
  if (report_parts_school$student_voice_ind3c) {
    doc <- officer::read_docx("Templates/ind3C.docx")
  } else {
    print('3C Blank')
    doc <- officer::read_docx("Templates/ind3C_blank.docx")
    doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
    return(doc)
  }

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind3C_header.png")
    doc <- add_rating_table(doc, header)}
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind3c_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind3c_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  doc <- add_class_obs(doc,reportData, reportText, static_text,"RSP", "StudentPerspective", "tbl3c",separate_intro = TRUE, temp_stem, class_obs_bullets_school,4, special_class_obs = FALSE)

  fig3c <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig3c.png")
  doc <- add_staff_survey_response(doc, fig3c, height = 1.74)

  bullets <- c(static_text$ind3c_staff_perspective1, static_text$ind3c_staff_perspective2, static_text$ind3c_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind3c_student_perspective1, static_text$ind3c_student_perspective2, static_text$ind3c_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind3D <- function(static_text, ind_student_perspec, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind3D.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){  
    header <- paste0(temp_stem, "/Temp/Tables/ind3D_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind3d_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind3d_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  tbl5e <- paste0(temp_stem, "/Temp/Tables/5e_tbl3d.png")
  plot5e <- paste0(temp_stem, "/Temp/Tables/5e_table_graphic_tbl3d.png")
  doc <- add_5e(doc, tbl5e, plot5e, 1.76)
  
  fig3d_1 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig3d.1.png")
  doc <- add_staff_survey_response(doc, fig3d_1, staff_survey_text = "staffSurvey", height = 2.2)
  fig3d_2 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig3d.2.png")
  doc <- add_staff_survey_response(doc, fig3d_2, staff_survey_text = "surveyStaff", 2.56)

  bullets <- c(static_text$ind3d_staff_perspective1, static_text$ind3d_staff_perspective2, static_text$ind3d_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    doc <- officer::cursor_reach(doc, 'headerPgBreak')
    doc <- officer::body_add_par(doc, "INDICATOR 3.D: FAMILY COLLABORATION (CONT.)", style='Heading 3 No TOC', pos = 'before')
    doc <- officer::body_add_break(doc, pos = 'before')
    doc <- officer::cursor_reach(doc, 'headerPgBreak')
    doc <- officer::body_remove(doc)
    
    bullets <- c(static_text$ind3d_student_perspective1, static_text$ind3d_student_perspective2, static_text$ind3d_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::cursor_reach(doc, 'headerPgBreak')
    doc <- officer::body_remove(doc)
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind3E <- function(static_text, ind_student_perspec, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind3E.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind3E_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind3e_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind3e_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig3e <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig3e.png")
  doc <- add_staff_survey_response(doc, fig3e, height = 1.74)
 
  bullets <- c(static_text$ind3e_staff_perspective1, static_text$ind3e_staff_perspective2, static_text$ind3e_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    doc <- officer::cursor_reach(doc, 'headerPgBreak')
    doc <- officer::body_add_par(doc, "INDICATOR 3.E: COMMUNITY RESOURCES AND ENGAGEMENT (CONT.)", style='Heading 3 No TOC', pos = 'before')
    doc <- officer::body_add_break(doc, pos = 'before')
    doc <- officer::cursor_reach(doc, 'headerPgBreak')
    doc <- officer::body_remove(doc)
    
    bullets <- c(static_text$ind3e_student_perspective1, static_text$ind3e_student_perspective2, static_text$ind3e_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::cursor_reach(doc, 'headerPgBreak')
    doc <- officer::body_remove(doc)
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }
  

  return(doc)
}

add_ind4A_schools_like_us <- function(static_text, ind_student_perspec, school, temp_stem, slu_text) {
  doc <- officer::read_docx("Templates/ind4A_schoolsLikeUs.docx")
  doc <- add_schools_like_us(doc, slu_text)
  
  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)


  return(doc)
}

add_ind4A_continued <- function(static_text, ind_student_perspec, school, temp_stem) {
  doc <- officer::read_docx("Templates/ind4A_continued.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind4A_header.png")
    doc <- add_rating_table(doc, header)
  }
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind4a_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind4a_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig4a <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig4a.png")
  doc <- add_staff_survey_response(doc, fig4a, height = 3.02)

  bullets <- c(static_text$ind4a_staff_perspective1, static_text$ind4a_staff_perspective2, static_text$ind4a_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind4a_student_perspective1, static_text$ind4a_student_perspective2, static_text$ind4a_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind4B <- function(reportData, static_text, reportText, ind_student_perspec, report_parts_school, school, temp_stem, class_obs_bullets_school) {
  doc <- officer::read_docx("Templates/ind4B.docx")

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind4B_header.png")
    doc <- add_rating_table(doc, header)
  }
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind4b_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind4b_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  doc <- add_class_obs(doc,reportData, reportText, static_text,"ILF", "InstructionalFormat", "tbl4b.1",separate_intro = TRUE, temp_stem, class_obs_bullets_school,7, special_class_obs = FALSE)
  
  if(report_parts_school$quality_feedback == TRUE | report_parts_school$student_engagement == TRUE){
    doc <- officer::cursor_reach(doc, 'pageBreak')
    doc <- officer::body_remove(doc)
    doc <- officer::body_add_par(doc, "INDICATOR 4.B: INCLUSIVE AND DIFFERENTIATED INSTRUCTION (CONT.)", style='Heading 3 No TOC', pos = 'before')
    doc <- officer::body_add_break(doc, pos = 'before')
    
  } else {
    doc <- officer::cursor_reach(doc, 'pageBreak')
    doc <- officer::body_remove(doc)
  }
  
  if(report_parts_school$quality_feedback == TRUE){
    doc <- officer::cursor_reach(doc, "classObsQFTitle")
    doc <- officer::body_add_par(doc, "CLASSROOM OBSERVATIONS: QUALITY OF FEEDBACK", style = "Heading 4 No TOC", pos = 'after')
    doc <- officer::body_replace_all_text(doc, "classObsQFTitle", "")
    doc <- add_class_obs(doc,reportData, reportText, static_text,"QF", "QualityFeedback", "tbl4b.2",separate_intro = TRUE, temp_stem, class_obs_bullets_school,9, special_class_obs = FALSE)
    doc <- officer::body_replace_all_text(doc, "QFFootnote", "")
  } else {
    doc <- officer::cursor_reach(doc, "QFFootnote")
    doc <- officer::body_remove(doc)
    doc <- officer::body_replace_all_text(doc, "classObsQFTitle", "")
    doc <- officer::body_replace_all_text(doc, "classObsQFText", "")
    doc <- officer::body_replace_all_text(doc, "classObsQFTable", "")
    doc <- officer::body_replace_all_text(doc, "classObsQFBullets", "")
  }

  if(report_parts_school$student_engagement == TRUE){
    doc <- officer::cursor_reach(doc, "classObsSETitle")
    doc <- officer::body_add_par(doc, "CLASSROOM OBSERVATIONS: STUDENT ENGAGEMENT", style = "Heading 4 No TOC", pos = 'after')
    doc <- officer::body_replace_all_text(doc, "classObsSETitle", "")
    doc <- add_class_obs(doc,reportData, reportText, static_text,"SE", "StudentEngagement", "tbl4b.3",separate_intro = FALSE, temp_stem, class_obs_bullets_school,12, special_class_obs = FALSE)
    doc <- officer::body_replace_all_text(doc, "SEFootnote1", "")
    
    if (report_parts_school$concept_development == TRUE && report_parts_school$content_understanding == TRUE){
      doc <- officer::body_replace_all_text(doc, "SEFootnote2", "")
    }else{
      doc <- officer::cursor_reach(doc, "SEFootnote2")
      doc <- officer::body_remove(doc)
    }
    
  } else {
    doc <- officer::cursor_reach(doc, "SEFootnote1")
    doc <- officer::body_remove(doc)
    doc <- officer::cursor_reach(doc, "SEFootnote2")
    doc <- officer::body_remove(doc)
    doc <- officer::body_replace_all_text(doc, "classObsSETitle", "")
    doc <- officer::body_replace_all_text(doc, "classObsSEText", "")
    doc <- officer::body_replace_all_text(doc, "classObsSETable", "")
    doc <- officer::body_replace_all_text(doc, "classObsSEBullets", "")
  }
  
  fig4b <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig4b.png")
  doc <- add_staff_survey_response(doc, fig4b, height = 3.02)

  bullets <- c(static_text$ind4b_staff_perspective1, static_text$ind4b_staff_perspective2, static_text$ind4b_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind4b_student_perspective1, static_text$ind4b_student_perspective2, static_text$ind4b_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind4C <- function(static_text, ind_student_perspec, report_parts_school, school, temp_stem) {
  if (report_parts_school$enrichment_ind4c) {
    doc <- officer::read_docx("Templates/ind4C.docx")
  } else {
    print('4C Blank')
    doc <- officer::read_docx("Templates/ind4C_blank.docx")
    doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
    return(doc)
  }

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind4C_header.png")
    doc <- add_rating_table(doc, header)
  }
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind4c_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind4c_overall_rating
  doc <- add_overall_text(doc, overallText)
  
  fig4c_1 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig4c.1.png")
  doc <- add_staff_survey_response(doc, fig4c_1, staff_survey_text = "staffSurvey", height = 2.56)
  fig4c_2 <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig4c.2.png")
  doc <- add_staff_survey_response(doc, fig4c_2, staff_survey_text = "surveyStaff", height = 2.56)

  bullets <- c(static_text$ind4c_staff_perspective1, static_text$ind4c_staff_perspective2, static_text$ind4c_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind4c_student_perspective1, static_text$ind4c_student_perspective2, static_text$ind4c_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}

add_ind4D <- function(static_text, ind_student_perspec, report_parts_school, school, temp_stem) {
  if (report_parts_school$college_ind4d) {
    doc <- officer::read_docx("Templates/ind4D.docx")
  } else {
    print('4D Blank')
    doc <- officer::read_docx("Templates/ind4D_blank.docx")
    doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
    
    return(doc)
  }

  doc <- officer::footers_replace_all_text(doc, "schoolName", school, warn = FALSE)
  
  if(officer::cursor_reach_test(doc, 'ratingTable')){
    header <- paste0(temp_stem, "/Temp/Tables/ind4D_header.png")
  doc <- add_rating_table(doc, header)
  }
  
  
  
  introText <- static_text$indicator_intro_language_based_on_rating_from_select_ind4d_rating
  doc <- add_intro_text(doc, introText)
  
  overallText <- static_text$ind4d_overall_rating
  doc <- add_overall_text(doc, overallText)
  


  fig4d <-  paste0(temp_stem, "/Temp/Tables/survey_response_graphic_fig4d.png")
  doc <- add_staff_survey_response(doc, fig4d, height = 3.02)

  bullets <- c(static_text$ind4d_staff_perspective1, static_text$ind4d_staff_perspective2, static_text$ind4d_staff_perspective3)
  doc <- add_bullets(doc, 'staffPerspective', bullets)
  
  if(ind_student_perspec == 'full'){
    bullets <- c(static_text$ind4d_student_perspective1, static_text$ind4d_student_perspective2, static_text$ind4d_student_perspective3)
    doc <- add_bullets(doc, 'studentPerspective', bullets)
  } else {
    doc <- officer::body_replace_all_text(doc, 'studentPerspective', '')
  }

  return(doc)
}
