############################################################################ Figures ######################################################################################


# Prepare data for the figures
cleanDataList_Fig <- function(data, figure, num_responses) {
  # data <- data[[figure]]
  
  num_responses <- num_responses$num_respondents[num_responses$rcdts == data$rcdts[1]]
  data <- data %>% select(-rcdts)
  
  # Process fig 4c.2 separately (the figure that's not a stacked bar)
  if (figure == "fig4c.2") {
    # data <- clean_fig4c2(data, num_responses)
    # return(data)
  }
  
  # Some reports have \" in the json values instead of ' causing issues, fixing here
  data <- data %>% mutate(value = gsub("\\\"", "'", value))
  
  # Make sure the categories are in the correct order
  category_order <- data.frame(
    labels = c("Strongly Disagree", "Disagree", "Agree", "Strongly Agree", "Less than monthly", "Monthly", "Multiple times per month", "Weekly or more", "Never", "Annually", "Semi-annually", "Quarterly or more", "No Response"),
    order = 1:13
  )
  
  #Loop through each row and get the categories present. Throw them into a vector and deduplicate. Sort and retrieve the labels in the figure
  category_labels_list <- lapply(1:nrow(data), function(i) {
    str_extract_all(data[i,]$value, "'[^:]+':")[[1]] %>% gsub("'|:", "", .)
  })
  category_labels_vec <- unique(do.call(c, category_labels_list))
  
  category_labels <- category_order %>% filter(labels %in% c(category_labels_vec,"No Response")) %>% arrange(order) %>% pull(labels)
  
  
  # Convert figure data from JSON format to a dataframe
  categories <- extract_JSON(data, category_order, category_labels)
  # Skip figures not being used
  if (all(is.na(categories))) {
    return(data)
  }
  
  # Add to figure data
  data <- data %>%
    bind_cols(categories) %>%
    select(-"value", -Subgroup)
  # Add bold section headers to figures
  data <- add_bold_fig_labels(data, category_labels)
  # Turn raw counts into percentages
  data <- counts_to_percents(data, category_labels)
  # Convert to long format
  data <- data %>% pivot_longer(-c(Report, Figure_num, Figure_name, Variable, Group), names_to = "Subgroup")
  # Convert subgroup to factor
  data$Subgroup <- factor(data$Subgroup, levels = rev(unique(data$Subgroup)))
  # Convert group & value to numeric
  data <- data %>% mutate(
    numeric_group = as.numeric(factor(Group, levels = rev(unique(Group)))),
    value = as.numeric(value)
  )
  # Filter out extra NA rows for cases where multiple scales are used
  data <- data %>% group_by(Group) %>% mutate(to_remove=ifelse(any(!is.na(value)) & any(is.na(value)), TRUE, FALSE)) %>% 
    ungroup() %>% filter(!(to_remove & is.na(value))) %>% select(-to_remove)
  # Create data labels
  data <- data %>%
    mutate(text_label = paste0(round(value * 100, 0), "%")) %>%
    group_by(Group) %>%
    mutate(text_location = cumsum(value)) %>%
    ungroup() %>%
    mutate(text_location = text_location - (.5 * value))
  data[data$text_label == "NA%", ]$text_label <- NA
  # Fix group label newlines
  data$Group <- gsub("\\\\n", "\\\n", data$Group)
  
  ### Recalculate the `text_label` only if total value in group is greater than 1 ###
  data <- data %>%
    group_by(Report, Group) %>%
    mutate(total_value = sum(value, na.rm = TRUE)) %>%
    mutate(recalc_text_label = ifelse(total_value > 1, paste0(round((value / total_value) * 100, 0), "%"), text_label)) %>%
    ungroup()
  
  # Replace `text_label` with recalculated label where applicable
  data <- data %>%
    mutate(text_label = ifelse(total_value > 1, recalc_text_label, text_label)) %>%
    select(-c(total_value, recalc_text_label))
  
  
  #NOTE: text location is NOT correct - missing for the other scale
  return(data)
}

# Convert JSON-formatted data for a figure to a dataframe
extract_JSON <- function(data, category_order, category_labels) {
  # Skip figures not being used
  if (all(is.na(data$Report))) {
    return(NA)
  }
  # Split up categories from each value
  i <- 9
  # categories <- sapply(1:nrow(data), function(i) {
  #   if (!is.na(data[i, ]$Report)) {
  #     cat_vec <- fromJSON(gsub("'", '"', data[i, ]$value)) %>% unlist()
  #     # Sort the vector to get the right category ordering
  #     cat_vec <- tibble(labels = names(cat_vec), values = cat_vec) %>%
  #       left_join(category_order, by = "labels") %>%
  #       arrange(order) %>%
  #       pull(values)
  #     ########################### Remove this when "No Response" is added to the data files ############################
  #     if (!"No Response" %in% names(cat_vec)) {
  #       cat_vec <- c(cat_vec, "No Response" = 0)
  #     }
  #     return(cat_vec)
  #   } else {
  #     na_list <- list(NA, NA, NA, NA, NA)
  #     names(na_list) <- category_labels
  #     na_list %>% unlist()
  #   }
  # }) %>%
  #   t() %>%
  #   as_tibble()
  # categories <- sapply(categories, as.character) %>% as_tibble()
  
  categories <- lapply(1:nrow(data), function(i) {
    if (!is.na(data[i, ]$Report)) {
      cat_vec <- fromJSON(gsub("'", '"', data[i, ]$value)) %>% unlist()
      
      cat_df <- cat_vec[order(match(names(cat_vec), category_order$labels))] %>% t() %>% as_tibble()
      if (!"No Response" %in% colnames(cat_df)) {
        cat_df <- cat_df %>% mutate(`No Response`=0)
      }
      return(cat_df)
      # # Sort the vector to get the right category ordering
      # cat_vec <- tibble(labels = names(cat_vec), values = cat_vec) %>%
      #   left_join(category_order, by = "labels") %>%
      #   arrange(order) %>% mutate(dummy=1) %>% pivot_wider(id_cols='dummy',names_from='labels',values_from='values') %>% select(-dummy)
      #   pull(values)
      # ########################### Remove this when "No Response" is added to the data files ############################
      # if (!"No Response" %in% names(cat_vec)) {
      #   cat_vec <- c(cat_vec, "No Response" = 0)
      # }
      # return(cat_vec)
    } else {
      # na_list <- list(NA, NA, NA, NA, NA)
      # names(na_list) <- category_labels
      # na_list %>% unlist()
      tibble('test1'=NA,'test2'=NA,'test3'=NA,'test4'=NA,'test5'=NA)
    }
  }) %>% bind_rows() 
  
  #Re-order columns
  categories <- categories %>% relocate(category_order$labels[category_order$labels %in% colnames(categories)]) %>% mutate(across(everything(), as.character))
  
  # categories %>%
  #   t() %>%
  #   as_tibble()
  # categories <- sapply(categories, as.character) %>% as_tibble()
  
  return(categories)
}

# Add rows to insert bold headers into a figure
add_bold_fig_labels <- function(data, category_labels) {
  if (any(grepl(" - ", data$Figure_name))) {
    bold_labels <- unique(gsub(".+ - ", "", data$Figure_name[grepl(" - ", data$Figure_name)]))
    for (label in bold_labels) {
      idx <- which(grepl(gsub("\\\\", "", label), gsub("\\\\", "", data$Figure_name, perl = TRUE)))[1]
      new_row <- data[idx, ]
      new_row[, c("Group", category_labels)] <- as.list(c(label, rep(NA, length(category_labels))))
      data <- data %>% add_row(new_row, .before = idx)
    }
  }
  return(data)
}

# Convert raw counts to percentages for a figure
counts_to_percents <- function(data, category_labels) {
  row_totals <- sapply(1:nrow(data), function(i) {
    sum(as.numeric(data[i, category_labels]), na.rm = TRUE)
  })
  
  data[, category_labels] <- lapply(data[, category_labels], as.numeric)
  for (i in 1:length(row_totals)) {
    if (!all(is.na(data[i, category_labels]))) {
      data[i, category_labels] <- data[i, category_labels] / row_totals[i]
    }
  }
  data[, category_labels] <- lapply(data[, category_labels], as.character)
  
  return(data)
}

# This figure is different from the other stacked bars and needs to be processed separately
clean_fig4c2 <- function(data, num_responses) {
  category_labels <- str_extract_all(data[1, ]$value, "'[^:]+':")[[1]] %>% gsub("'|:", "", .)
  # Split up categories from each value
  if (all(is.na(data$Report))) {
    next
  }
  categories <- sapply(1:nrow(data), function(i) {
    if (!is.na(data[i, ]$Report)) {
      cat_vec <- fromJSON(gsub("'", '"', data[i, ]$value)) %>% unlist()
      return(cat_vec)
    } else {
      na_list <- list(NA, NA, NA, NA, NA)
      names(na_list) <- category_labels
      na_list %>% unlist()
    }
  }) %>%
    t() %>%
    as_tibble()
  
  num_respondents <- num_responses
  # Add to figure data
  data <- data %>%
    bind_cols(categories) %>%
    select(-value, -Subgroup)
  
  data[, category_labels] <- data[, category_labels] / num_respondents
  # Convert to long format
  data <- data %>% pivot_longer(-c(Report, Figure_num, Figure_name, Variable, Group), names_to = "Subgroup")
  # bold title and reformat one label
  data$Group <- paste0("<b>", data$Group, "</b>")
  data$Subgroup <- gsub("Sports/Exercise/Athletics", "<br>Sports/Exercise/<br>Athletics", data$Subgroup)
  # Convert subgroup to factor
  data$Subgroup <- factor(data$Subgroup, levels = unique(data$Subgroup))
  # Create data labels
  data <- data %>% mutate(text_label = paste0(round(value * 100, 0), "%"))
  data[data$text_label == "NA%", ]$text_label <- "0%"
  
  return(data)
}

############################################################################ Tables #######################################################################################

# Prepare data for the tables
cleanDataList_Table <- function(data, grade_bands, name) {
  # data <- data[[table]]
  ## Grade Table Data
  if (any(grepl("Grade Table", data$Figure_name))) {
    data <- clean_grade_table(data, grade_bands, name)
  }
  ## 5Essentials Table Data
  else if (any(grepl("5Essentials Table", data$Figure_name))) {
    data <- clean_5essentials_table(data)
  }
  ## Indicator Turnaround Table Data
  else {
    data <- clean_ind_turnaround_table(data)
  }
  
  return(data)
}

# Clean class obs grade table
clean_grade_table <- function(data, grade_bands, name) {
  if (all(is.na(data$Report))) {
    return(data)
  }
  
  data <- data %>% slice(which(!is.na(value)))
  
  school_grade_bands <- grade_bands %>%
    filter(rcdts == data$rcdts[1])
  # grade_band_list <- extract_values(school_grade_bands)
  
  data <- data %>% select(-rcdts)
  
  # Split up categories from each value
  categories <- sapply(1:nrow(data), function(i) {
    fromJSON(gsub("(\\w):", '"\\1":', data[i, ]$value)) %>% unlist()
  }) %>%
    t() %>%
    as_tibble()
  # Add to table data
  data <- data %>%
    bind_cols(categories) %>%
    select(-value, -Subgroup)
  
  # Add counts and avg
  counts <- data %>% select(-Report, -Figure_num, -Figure_name, -Variable, -Group)
  # test <- rowSums(counts)
  data["n"] <- rowSums(counts)
  data[["Average"]] <- unlist(lapply(1:length(rowSums(counts)), function(n) {
    round(sum(unlist(lapply(1:length(counts), function(i) {
      i * counts[n, i]
    }))) / rowSums(counts)[n], 1)
  }))
  
  # Remove rows with NA in 'Average' column
  data <- data[!is.na(data$Average), ]
  
  #### This is where we handle changing the grade bands based on what the school wants the label to put
  ## TODO: Put in a check for when length of grade bands dont match up ##
  
  if (!is.na(school_grade_bands$lower)) {
    data$Group <- gsub("Lower Elementary", school_grade_bands$lower, data$Group)
  }
  if (!is.na(school_grade_bands$upper)) {
    data$Group <- gsub("Upper Elementary", school_grade_bands$upper, data$Group)
  }
  if (!is.na(school_grade_bands$secondary)) {
    data$Group <- gsub("Secondary", school_grade_bands$secondary, data$Group)
  }
  
  # if(length(grade_band_list) == length(data$Group)){
  #   data$Group <- grade_band_list
  # }
  
  return(data)
}

# Clean 5essentials table
clean_5essentials_table <- function(data) {
  data <- data %>% select(-rcdts)
  data <- data %>% pivot_wider(names_from = Subgroup, values_from = value)
  data$Score <- as.numeric(data$Score)
  # Add rating labels
  data <- data %>% mutate(Rating = case_when(
    Score < 20 ~ "\\textbf{\\textcolor{thetextorange}{Very Weak}}",
    Score < 40 ~ "\\textbf{\\textcolor{thetextorange}{Weak}}",
    Score < 60 ~ "\\textbf{\\textcolor{thetextgrey}{Neutral}}",
    Score < 80 ~ "\\textbf{\\textcolor{thetextblue}{Strong}}",
    Score <= 100 ~ "\\textbf{\\textcolor{thetextblue}{Very Strong}}",
    is.na(Score) ~ "\\textbf{\\textcolor{thetextgrey}{No Data}}"
  ))
  data <- data %>% mutate(Score = ifelse(is.na(Score), "NA", Score))
  
  return(data)
}

# Clean indicator turnaround table
clean_ind_turnaround_table <- function(data) {
  # data <- data[[table]]
  
  data <- data %>% select(-rcdts)
  data$value[data[['value']] == ""] <- "NA"
  # Convert data to wide format for use in table, converting values to the "X" that will be shown
  data <- data %>% pivot_wider(names_from = value)
  if ("NA" %in% colnames(data)) {
    data <- data %>%
      select(-`NA`)
  }
  
  if (!"Initial" %in% colnames(data)) {
    data <- data %>% mutate(Initial = as.character(NA))
  }
  if (!"Emerging" %in% colnames(data)) {
    data <- data %>% mutate(Emerging = as.character(NA))
  }
  if (!"Established" %in% colnames(data)) {
    data <- data %>% mutate(Established = as.character(NA))
  }
  if (!"Robust" %in% colnames(data)) {
    data <- data %>% mutate(`Robust` = as.character(NA))
  }
  data <- data %>%
    relocate("Initial", .after = "Subgroup") %>%
    relocate("Emerging", .after = "Initial") %>%
    relocate("Established", .after = "Emerging") %>%
    relocate("Robust", .after = "Established") %>%
    mutate_at(c("Initial", "Emerging", "Established", "Robust"), ~ ifelse(!is.na(.), "X", ""))
  # Convert rows not used by report to dashes
  # Tracking is.na(data$Report) was how these excluded rows were identified in the past. This seems to not be the case any more
  # data[is.na(data$Report),c("Initial","Emerging","Established", "Robust")] <- "-"
  # Instead, check if all are empty to insert dashes
  empty_rows <- sapply(1:nrow(data), function(i) {
    all(data[i, c("Initial", "Emerging", "Established", "Robust")] == c("", "", "", ""))
  })
  data[empty_rows, c("Initial", "Emerging", "Established", "Robust")] <- list("-", "-", "-", "-")
  
  
  return(data)
}