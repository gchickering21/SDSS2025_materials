

check_oasis_form_completeness <- function(df, column_name) {
  
  if (nrow(df) == 0) {
    print(paste("OASIS has no form data for this school"))
    return(FALSE)
  }
  
  # Ensure the column exists
  if (!(column_name %in% colnames(df))) {
    stop(paste("Column", column_name, "not found in the data frame"))
  }
  
  # Expected incomplete pattern
  incomplete_pattern <- c('1' = 0, '2' = 0, '3' = 0, '4' = 0, '5' = 0, '6' = 0, '7' = 0)
  
  # Extract the value from the specified column
  value <- df[[column_name]]
  
  # Check if the value matches the incomplete pattern
  is_incomplete <- identical(as.list(table(value)), as.list(incomplete_pattern))
  
  # Return TRUE if complete, FALSE if incomplete
  return(!is_incomplete)
}

## Function to check if oasis and airtable agree with each other
check_oasis_airtable_agreement <- function(oasis_value, airtable_value){
  if(oasis_value == airtable_value){
    return(TRUE)
  }
  if(oasis_value != airtable_value && oasis_value == TRUE){
    warning_message <- "Oasis form Filled Out but Airtable MISSING this Grade Band"
    return(warning_message)
  }
  if(oasis_value != airtable_value && oasis_value == FALSE){
    warning_message <- "Oasis form NOT filled out but Airtable Has this Grade Band"
    return(warning_message)
  }
  
}

########## Here is where we do the actual WARNING CHECK ###############
i <- 1
for(i in 1:nrow(pre_reports)){
  pre_reports_rcdts <- pre_reports[i,"rcdts"]
  
  ## Arbitrarily choosing PC Rating - could be any of the rating variables
  oasis_k_3_df <- class_obs_k_3_aggregate %>%
    filter(rcdts == pre_reports_rcdts) %>%
    select(rcdts,school_and_district_name,  'PC RATING')
  
  oasis_upper_elementary_df  <- class_obs_upper_elementary_aggregate %>%
    filter(rcdts == pre_reports_rcdts) %>%
    select(rcdts,school_and_district_name, 'PC RATING UPPER')
  
  oasis_secondary_df <- class_obs_secondary_aggregate %>%
    filter(rcdts == pre_reports_rcdts) %>%
    select(rcdts, school_and_district_name, 'PC RATING SECONDARY')
  
  ## Now check to see if the corresponding form has responses
  ##TRUE means there are entries
  oasis_k_3 <- check_oasis_form_completeness(oasis_k_3_df, 'PC RATING')
  oasis_upper_elementary <- check_oasis_form_completeness(oasis_upper_elementary_df, 'PC RATING UPPER')
  oasis_secondary <- check_oasis_form_completeness(oasis_secondary_df, 'PC RATING SECONDARY')
  
  print(oasis_k_3)
  print(oasis_upper_elementary)
  print(oasis_secondary)
  
  ##Now check Airtable columns that have been selected
  airtable_grade_band <- grade_bands %>%
    filter(rcdts == pre_reports_rcdts)
  
  airtable_k_3 <- airtable_grade_band$lower != "NaN"
  airtable_upper_elementary <- airtable_grade_band$upper != "NaN"
  airtable_secondary <- airtable_grade_band$secondary != "NaN"
  
  ## Now check to see if airtable and oasis values match up and if not add a warning
  
  agr_k_3 <- check_oasis_airtable_agreement(oasis_k_3, airtable_k_3)
  agr_upper_elementary <- check_oasis_airtable_agreement(oasis_upper_elementary, airtable_upper_elementary)
  agr_secondary <- check_oasis_airtable_agreement(oasis_secondary, airtable_secondary)
  
  agr_list <- c(agr_k_3, agr_upper_elementary, agr_secondary)
  
  for(i in agr_list){
    if(i != TRUE){
      print("Still Need to Add Warning Check")
      ##ADD IN WARNING UPDATE HERE
    }
  }
  
}
