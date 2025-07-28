## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
# AUTHOR: Graham Chickering
# Purpose: Create ILNA Data Package 
# DATE CREATED:
# 02/29/2024
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## ----------- Generate Entire Data Package   ----------------------------------------------------------------------------- ##
generate_data_package <- function(rcdts_id, name_school_district, folder, school_template_database_variables_needed, text_data, combined_database_df, qc_staff_survey_temp, class_obs_aggregate_combined, school_grade_bands,qc_class_obs_temp,class_obs_notes, prelim_notes,review_file_temp){
  update_wb <- createWorkbook()
  # Add sheets to the workbook
  sheet_names <- c("UpdateText", "Review_Notes", "ClassObsNotes", "PrelimNotes")
  for (sheet_name in sheet_names) {
    addWorksheet(update_wb, sheet_name)
  }
  update_text_excel_output_file <- paste0(folder, "/", name_school_district, "_Update_Text.xlsx")
  saveWorkbook(update_wb,update_text_excel_output_file, overwrite = TRUE)
  
  update_wb <- generate_review_sheet(review_file_temp,update_wb,update_text_excel_output_file  )
  saveWorkbook(update_wb, update_text_excel_output_file, overwrite = TRUE)
  
  
  update_wb <- generate_school_update_text(name_school_district, school_template_database_variables_needed, text_data, update_wb,update_text_excel_output_file )
  saveWorkbook(update_wb, update_text_excel_output_file, overwrite = TRUE)
  
  update_wb <- generate_class_obs_notes(rcdts_id,name_school_district, class_obs_notes, update_wb, update_text_excel_output_file )
  saveWorkbook(update_wb, update_text_excel_output_file, overwrite = TRUE)
  
  update_wb <- generate_preliminary_rating_notes(rcdts_id,name_school_district, prelim_notes, update_wb, update_text_excel_output_file )
  saveWorkbook(update_wb, update_text_excel_output_file, overwrite = TRUE)
  
  ## Here is where we create the Data Pakkage file and other QC documents if its a v1 report
  data_wb <- createWorkbook()
  # Add sheets to the workbook
  sheet_names <- c("Staff_Survey_QC", "Class_Observation_QC")
  for (sheet_name in sheet_names) {
    addWorksheet(data_wb, sheet_name)
  }
  
  data_excel_output_file <- paste0(folder, "/", name_school_district, "_Data_Package.xlsx")
  saveWorkbook(data_wb, data_excel_output_file , overwrite = TRUE)
  
  data_wb <- generate_staff_survey_qc(rcdts_id,name_school_district, combined_database_df,qc_staff_survey_temp, data_wb,data_excel_output_file)
  saveWorkbook(data_wb, data_excel_output_file , overwrite = TRUE)
  
  class_obs_aggregate_combined_fixed <- cleanup_school_names(class_obs_aggregate_combined,'school_and_district_name') 
  data_wb <- generate_class_obs_qc(rcdts_id,name_school_district, class_obs_aggregate_combined_fixed, data_wb, data_excel_output_file,school_grade_bands,qc_class_obs_temp)
  saveWorkbook(data_wb, data_excel_output_file , overwrite = TRUE)
  
}

## ----------- Generate Review Sheet in Update Text File   -----------------------------------------------------------------------------
generate_review_sheet <- function( review_file_temp, wb, output_file){
  # Write data to the 'UpdateText' sheet
  writeData(wb, sheet = "Review_Notes", x = review_file_temp, rowNames = FALSE)
  blueStyle <- createStyle(fgFill = '#006E9F', fontColour = "#ffffff")
  addStyle(wb,
           sheet = "Review_Notes", cols = 1:5,rows = 1,
           style = blueStyle, gridExpand = TRUE
  )
  
  setColWidths(wb, sheet ="Review_Notes", cols = 1, widths = 12)
  setColWidths(wb, sheet ="Review_Notes", cols = 2, widths = 20)
  setColWidths(wb, sheet ="Review_Notes", cols = 3, widths = 40)
  setColWidths(wb, sheet ="Review_Notes", cols = 4, widths = 20)
  setColWidths(wb, sheet ="Review_Notes", cols = 5, widths = 20)
  
  saveWorkbook(wb, output_file, overwrite = TRUE)
  ###print("Review Sheet Successfully Created")
  return(wb)
}

## ----------- Generate UpdateText File   -----------------------------------------------------------------------------
generate_school_update_text <- function(school_name, data_df, text_data, wb, output_file) {
  ilna_template2 <- ilna_template %>%
    left_join(data_df, by = c("DB_Variable" = "DB_Variable")) %>%
    mutate(Rating = DB_Value) %>%
    select(-c(school_and_district_name, DB_Value))
  
  ilna_template3 <- ilna_template2 %>%
    left_join(text_data, by = c("Description" = "Description", "Rating" = "Rating")) %>%
    mutate(Text.x = Text.y) %>%
    select(-c(Text.y, Variable, Indicator)) %>%
    rename(Text = Text.x)
  
  ilna_template4 <- ilna_template3 %>%
    mutate(Rating = ifelse(grepl("OverallRating", Description), NA, Rating)) %>%
    select(-c(DB_Variable, rcdts))
  
  # Write data to the 'UpdateText' sheet
  writeData(wb, sheet = "UpdateText", x = ilna_template4, rowNames = FALSE)
  
  wrapStyle <- createStyle(fontColour = "#000000", wrap = TRUE)
  addStyle(wb,
           sheet = "UpdateText", cols = 6,rows = 2:192,
           style = wrapStyle, gridExpand = TRUE
  )
  
  setColWidths(wb, sheet ="UpdateText", cols = 1, widths = 22)
  setColWidths(wb, sheet ="UpdateText", cols = 3, widths = 40)
  setColWidths(wb, sheet ="UpdateText", cols = 4, widths = 30)
  
  saveWorkbook(wb, output_file, overwrite = TRUE)
  ###print("Update Text Successfully Created")
  return(wb)
}

## ----------- Generate Staff Survey File   ----------------------------------------------------------------------------- ##
generate_staff_survey_qc <- function(rcdts_id, school_name,combined_database_df, qc_staff_survey_temp, wb,output_file ){
  staff_survey_qc <- combined_database_df %>%
    filter( rcdts == rcdts_id)%>%
    select(contains("question"))
  
  
  staff_survey_qc_2 <- staff_survey_qc %>%
    pivot_longer(cols = starts_with("question"), names_to = "question", values_to = "responses") %>%
    separate_rows(responses, sep = ", ") %>%
    separate(responses, into = c("responses", "value"), sep = ": ") %>%
    mutate(responses = gsub("[{}']", "", responses),
           value = gsub("[{}']", "", value),
           value = as.numeric(value)) %>%
    group_by(question) %>%
    mutate(percent = paste0(round(value / sum(value) * 100, 0), '%')) %>%
    arrange(desc(question)) %>%
    select(-c(value)) %>%
    mutate(responses = case_when(
      question == 'question19' ~ case_when(
        tolower(responses) == 'advanced coursework' ~ 'Advanced Coursework',
        tolower(responses) == 'foreign languages' ~ 'Foreign Languages',
        tolower(responses) == 'clubs' ~ 'Clubs',
        tolower(responses) == 'electives' ~ 'Electives',
        tolower(responses) == 'sports/exercise/athletics' ~ 'Sports/Exercise/Athletics',
        TRUE ~ responses
      ),
      TRUE ~ responses  # Keep unchanged for other questions
    )) %>%
    pivot_wider(names_from = responses, values_from = percent, values_fill = NA)
  
  staff_survey_qc_3 <- qc_staff_survey_temp %>%
    left_join(staff_survey_qc_2, by = c('index' = 'question'))%>%
    select(index, 'No Response', 'Strongly Disagree', 'Disagree', 'Agree', 'Strongly Agree',
           'Never',  'Twice Per Year','Quarterly', 'Annually', 
           "Advanced Coursework",'Clubs', 'Electives','Foreign Languages', 'Sports/Exercise/Athletics',Page,
           Group) 
  # Write data to the 'Staff_Survey_QC' sheet
  writeData(wb, "Staff_Survey_QC", staff_survey_qc_3, rowNames = FALSE)
  
  #b2f7bf
  wrapStyle <- createStyle(fontColour = "#000000", wrap = TRUE)
  orangeStyle <- createStyle(fgFill = '#F9A872')
  lightOrangeStyle <- createStyle(fgFill = '#FDD1B0')
  lightBlueStyle <- createStyle(fgFill = '#98C7E8', fontColour = "#000000")
  blueStyle <- createStyle(fgFill = '#006E9F', fontColour = "#ffffff")
  lightGreenStyle <- createStyle(fgFill = '#93e69a')
  grayStyle<- createStyle(fgFill = '#c4c3c2')
  
  # New style for the bottom part with bold and color
  bottomRowStyle <- createStyle( border = "Bottom")
  
  # Go through and add bolding to bottom of different page rows
  rows_to_bold <- c(1, 3, 6, 8, 12, 16, 20, 23, 26, 31, 35, 38, 47, 51, 58, 64, 70, 76)  # Define rows to bold
  for (row in rows_to_bold) {
    addStyle(wb,
             sheet = "Staff_Survey_QC",
             cols = 1:17,
             rows = row,
             style = bottomRowStyle
    )
  }
  
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 16,rows = 2:76,
           style = wrapStyle, gridExpand = TRUE
  )
  ## Add in Colors
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 2,rows = c(2:69, 71:76),
           style = grayStyle
  )
  ### Strongly Disagree - Strongly Agree
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 3, rows = c(2:6,9:20, 27:69, 71:76),
           style = orangeStyle
  )
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 4, rows = c(2:6,9:20, 27:69, 71:76 ),
           style = lightOrangeStyle
  )
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 5, rows = c(2:6,9:20, 27:69, 71:76 ),
           style = lightBlueStyle
  )
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 6, rows = c(2:6,9:20, 27:69, 71:76 ),
           style = blueStyle
  )
  
  ### Never - Quarterly
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 7, rows = c(7:8, 21:26 ),
           style = orangeStyle
  )
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 8, rows = c(7:8, 21:26 ),
           style = lightOrangeStyle
  )
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 9, rows = c(7:8, 21:26 ),
           style = lightBlueStyle
  )
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 10, rows = c(7:8, 21:26 ),
           style = blueStyle
  )
  
  
  # Add in Page row styling
  addStyle(wb,
           sheet = "Staff_Survey_QC", cols = 16, rows = 2:76,
           style = lightGreenStyle
  )
  
  # Create bold versions
  boldOrangeStyle <- createStyle(fgFill = '#F9A872', border = "Bottom")
  boldLightOrangeStyle <- createStyle(fgFill = '#FDD1B0', border = "Bottom")
  boldLightBlueStyle <- createStyle(fgFill = '#98C7E8', fontColour = "#000000", border = "Bottom")
  boldBlueStyle <- createStyle(fgFill = '#006E9F', fontColour = "#ffffff", border = "Bottom")
  boldLightGreenStyle <- createStyle(fgFill = '#93e69a', border = "Bottom")
  boldGrayStyle<- createStyle(fgFill = '#c4c3c2', border = "Bottom")
  boldYellowStyle<- createStyle(fgFill = '#f7e1bc', border = "Bottom")
  
  # Define rows to bold
  rows_to_bold <- c(3, 6, 8, 12, 16, 20, 23, 26, 31, 35, 38, 47, 51, 58, 64, 70, 76)
  for (row in rows_to_bold) {
    if (row %in% c(3, 6, 12, 16, 20, 31, 35, 38, 47, 51, 58, 64, 76)) {
      # Apply styles to each column within the row
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 3,
               rows = row,
               style = boldOrangeStyle
      )
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 4,
               rows = row,
               style = boldLightOrangeStyle
      )
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 5,
               rows = row,
               style = boldLightBlueStyle
      )
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 6,
               rows = row,
               style = boldBlueStyle
      )
    }
    if(row %in% c(70)){
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 11:15,
               rows = row,
               style = boldYellowStyle
      )
    }
    if (row %in% c(8,23, 26)) {
      # Apply styles to each column within the row
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 7,
               rows = row,
               style = boldOrangeStyle
      )
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 8,
               rows = row,
               style = boldLightOrangeStyle
      )
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 9,
               rows = row,
               style = boldLightBlueStyle
      )
      addStyle(wb,
               sheet = "Staff_Survey_QC",
               cols = 10,
               rows = row,
               style = boldBlueStyle
      )
    }
    if (!(row %in% c(70))) {
      # Add in Page row styling
      addStyle(wb,
               sheet = "Staff_Survey_QC", cols = 2, rows = row,
               style = boldGrayStyle
      )
    }
    
    addStyle(wb,
             sheet = "Staff_Survey_QC", cols = 16, rows = row,
             style = boldLightGreenStyle
    )
  }
  
  
  
  setColWidths(wb, sheet ="Staff_Survey_QC", cols = 1, widths = 20)
  setColWidths(wb, sheet ="Staff_Survey_QC", cols = 2:10, widths = 18)
  setColWidths(wb, sheet ="Staff_Survey_QC", cols = 16, widths = 10)
  setColWidths(wb, sheet ="Staff_Survey_QC", cols = 17, widths = 50)
  
  
  saveWorkbook(wb, output_file, overwrite = TRUE)
  ###print("Staff Survey QC Successfully Created")
  return(wb)
}

## ----------- Generate Class Observation QC Sheet   ----------------------------------------------------------------------------- ##

# Function to extract counts from rating string
extract_counts <- function(dict_string, levels) {
  dict_string <- gsub("'", "\"", dict_string)  # Make it JSON-like
  parsed <- tryCatch({
    fromJSON(dict_string)  # Attempt to parse
  }, error = function(e) {
    return(rep(0, length(levels)))  # Return zeros if parsing fails
  })
  
  # Extract counts for each level
  counts <- sapply(levels, function(level) {
    if (toString(level) %in% names(parsed)) {
      return(as.numeric(parsed[[toString(level)]]))
    } else {
      return(0)  # Return 0 if the level isn't present
    }
  })
  
  return(counts)
}

# Function to replace abbreviation with full name but keep " RATING" and anything that follows
replace_abbr_with_full <- function(row_name, abbr_to_full) {
  for (abbr in names(abbr_to_full)) {
    pattern <- paste0("^", abbr, " ")
    if (grepl(pattern, tolower(row_name))) {
      replacement <- paste0(abbr_to_full[[abbr]], " ", substr(row_name, nchar(abbr) + 1, nchar(row_name)))
      return(replacement)
    }
  }
  return(row_name)
}

generate_class_obs_qc <- function(rcdts_id, school_name, agg_obs_data, wb, output_file, school_grade_bands,qc_class_obs_temp) {
  
  # Adjusted list with correct full names for matching to abbreviations
  abbr_to_full <- list(
    pc = 'POSITIVE CLIMATE',
    ts = 'TEACHER SENSITIVITY',
    bm = 'BEHAVIOR MANAGEMENT',
    ilf = 'INSTRUCTIONAL LEARNING FORMATS',
    qf = 'QUALITY OF FEEDBACK',
    cd = 'CONCEPT DEVELOPMENT',
    lm = 'LANGUAGE MODELING',
    pd = 'PRODUCTIVITY',
    se = 'STUDENT ENGAGEMENT',
    ai = 'ANALYSIS AND INQUIRY',
    rsp = 'REGARD FOR STUDENT PERSPECTIVE',
    nc = 'NEGATIVE CLIMATE',
    p = "PRODUCTIVITY",
    cu = "CONTENT UNDERSTANDING",
    id = "INSTRUCTIONAL DIALOGUE",
    rap = 'REGARD FOR STUDENT PERSPECTIVE'
  )
  
  # Filter data based on school_name
  filtered_df <- agg_obs_data %>%
    filter(rcdts == rcdts_id)
  
  # Extract rating types
  rating_types <- names(filtered_df)[grepl("RATING", names(filtered_df))]
  
  # Rating levels 1 through 7
  rating_levels <- 1:7
  new_df <- data.frame(matrix(ncol = length(rating_levels), nrow = length(rating_types)))
  colnames(new_df) <- as.character(rating_levels)
  rownames(new_df) <- rating_types
  
  # Loop over all rating types and populate the new dataframe
  for(rating_type in rating_types) {
    counts <- extract_counts(filtered_df[[rating_type]][1], rating_levels)
    new_df[rating_type, ] <- counts
  }
  
  # Calculate the weighted average rating for each rating type
  rating_levels_numeric <- as.numeric(colnames(new_df))  # Ensure numeric levels for calculation
  
  new_df$n <- apply(new_df, 1, function(row){
    total_counts <- sum(row)
    if (total_counts >= 0) {
      return(total_counts)  # Return the weighted average
    } else {
      return(NA)  # Return NA if there are no ratings
    }
  })
  
  new_df$AverageRating <- apply(new_df[, -which(names(new_df) == "n")], 1, function(row) {
    weighted_sum <- sum(row * rating_levels_numeric)  # Calculate weighted sum of ratings
    total_counts <- sum(row)  # Total number of ratings
    if (total_counts > 0) {
      return(weighted_sum / total_counts)  # Return the weighted average
    } else {
      return(NA)  # Return NA if there are no ratings
    }
  })
  

  
  
  
  # Update the row names in new_df
  new_row_names <- sapply(rownames(new_df), replace_abbr_with_full, abbr_to_full)
  
  # Apply the new row names to new_df
  rownames(new_df) <- new_row_names
  new_df$Category <- rownames(new_df)

  
  # Convert 'Category' values to lowercase
  new_df$Category <- gsub("RATING", "", new_df$Category)
  new_df$Category <- gsub(" ", " ", new_df$Category)
  
  
  # Conditionally assign grade bands
  school_grade_band <- ifelse(str_detect(new_df$Category, "UPPER"), school_grade_bands$upper[1], 
                       ifelse(str_detect(new_df$Category, "SECONDARY"), school_grade_bands$secondary[1], school_grade_bands$lower[1]))
  
  # Drop rows with NA in "AverageRating"
  new_df <- new_df %>%
    mutate(Grade_Band = school_grade_band) %>%
    filter(!is.na(AverageRating))%>%
    select(Grade_Band, Category, everything())
  
  new_df$Category <- gsub("UPPER", "", new_df$Category)
  new_df$Category <- gsub("SECONDARY", "", new_df$Category)
  new_df$Category<-trimws(new_df$Category)
  
  new_df <- new_df %>%
    arrange(Category)
  
  # Save 'class_observation_category' column before the join
  category_order <- qc_class_obs_temp$class_observation_category
  
  qc_class_obs_temp_joined <- new_df %>%
    left_join(qc_class_obs_temp, by = c("Category" = "class_observation_category")) %>%
    arrange(match(Category, category_order))%>%
    select(page_number, Category, Grade_Band, everything())%>%
    rename(Page_Number = page_number) %>%
    mutate(AverageRating = round(AverageRating, 2))
  
  # Create header row
  new_row <- data.frame(Page_Number = 'Page Number', Category = "Rating Categories",Grade_Band= "Grade Band",
                        `1` = "Low", `2` = "Low", `3` = "Middle",
                        `4` = "Middle", `5` = "Middle", `6` = "High", `7` = "High", `n` = NA, AverageRating = NA)
  
  # Define descriptive header values
  descriptive_header_values <- list("","","", "Low", "Low", "Middle", "Middle", "Middle", "High", "High", "","")
  
  # Write descriptive header to Excel sheet
  writeData(wb, sheet = "Class_Observation_QC", x = matrix(unlist(descriptive_header_values), nrow = 1), startRow = 1, startCol = 1, colNames = FALSE)
  
  # Prepare new_df for writing
  colnames(qc_class_obs_temp_joined) <- c("Page Number","Class Observation Category", "Grade Band", "1", "2", "3", "4", "5", "6", "7", "n", "AverageRating")
  
  # Write new_df to Excel sheet
  writeData(wb, sheet = "Class_Observation_QC", x = qc_class_obs_temp_joined, startRow = 2, startCol = 1, rowNames = FALSE)
  
  setColWidths(wb, sheet ="Class_Observation_QC", cols = 2, widths = 30)
  
  # Save workbook
  saveWorkbook(wb, output_file, overwrite = TRUE)
  
  ###print("Class Observation Data QC Successfully Created")
  return(wb)
}

## ----------- Generate Class Observation Notes Sheet   ----------------------------------------------------------------------------- ##

generate_class_obs_notes <- function(rcdts_id,school_name, data_df, wb, output_file) {
  # Adjusted list with correct full names for matching to abbreviations
  df_filtered <- data_df %>% 
    filter(rcdts == rcdts_id) %>%
    filter_at(vars(-level, -school_and_district_name), any_vars(!is.na(.))) %>%
    select(-c(rcdts))

  # Write data to the 'ClassObsNotes' sheet
  writeData(wb, sheet = "ClassObsNotes", x = df_filtered, rowNames = FALSE)
  
  setColWidths(wb, sheet ="ClassObsNotes", cols = 1, widths = 40)
  setColWidths(wb, sheet ="ClassObsNotes", cols = 2, widths = 25)

  saveWorkbook(wb, output_file, overwrite = TRUE)
  ###print("Class Observation Notes Successfully Created")
  
  return(wb)
}


## ----------- Generate Preliminary Rating Notes Sheet   ----------------------------------------------------------------------------- ##

generate_preliminary_rating_notes <- function(rcdts_id,school_name, prelim_notes, wb, output_file ){
  
  prelim_notes_filtered <- prelim_notes %>%
    filter(rcdts == rcdts_id) %>%
    rename("leadership_notes"= lvnotes, "cirriculum_notes" = cianotes, "culture_notes"= ccnotes, "targeted_instruction_notes" = tianotes) %>%
    filter_at(vars(-rcdts), any_vars(!is.na(.)))%>%
    select(-c(rcdts))
  
  # Write data to the '"PrelimNotes"' sheet
  writeData(wb, sheet = "PrelimNotes", x = prelim_notes_filtered, rowNames = FALSE)
  
  setColWidths(wb, sheet ="PrelimNotes", cols = 1, widths = 40)
  
  saveWorkbook(wb, output_file, overwrite = TRUE)
  ###print("Preliminary Rating Notes Successfully Created")
  
  return(wb)
    
}