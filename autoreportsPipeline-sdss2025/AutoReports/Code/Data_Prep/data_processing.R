# Function to perform any needed data cleaning steps BEFORE transforming the data into the format used for the reports
cleanData <- function(rawData) {
  data <- rawData

  # Convert all columns to character type to allow merging
  character_columns <- sapply(data, is.character)
  data[, !character_columns] <- lapply(data[, !character_columns], as.character)

  # #Drop duplicate column
  # data <- data %>% select(-`School Name`)

  # Convert numeric indicators to text
  # data <- data %>% mutate_at(which(grepl("^IND",colnames(data))), ~case_when(. == "1" ~ "Initial",
  #                                                                    . == "2" ~ "Emerging",
  #                                                                    . == "3" ~ "Established",
  #                                                                    . == "4" ~ "Robust"))
  # data <- cleanup_school_names(data, "Report")
  return(data)
}

# Function to extract values from columns
extract_values <- function(df) {
  df <- df %>%
    select(-full_name, -rcdts) %>% # Assuming 'list_column' is the name of your list column
    unlist() %>%
    na.omit()

  df <- unname(unlist(df))
  return(df)
}


# Function to perform any needed data cleaning steps on the data dictionary before transforming the data into the format used for the reports
cleanDataDict <- function(rawDataDict) {
  dataDict <- rawDataDict

  # Remove other columns containing comments and notes
  dataDict <- dataDict %>% select(Figure_num, Figure_name, Variable, Group, Subgroup)

  return(dataDict)
}

cleanDataList <- function(dataList, grade_bands, num_responses, rcdts_mapping) {
  # print(grade_bands)
  # dataList <- reportList
  # rcdts_mapping <- distinct(rawData[,c('rcdts','Report')])
  # rcdts_key <- rcdts_mapping$rcdts[1]
  # name <- names(dataList)[1]
  dataList <- foreach(
    i = 1:nrow(rcdts_mapping),
    .export = c(
      "cleanDataList_Fig", "cleanDataList_Table", "extract_JSON", "add_bold_fig_labels", "counts_to_percents",
      "clean_fig4c2", "clean_ind_turnaround_table", "clean_grade_table", "clean_5essentials_table", "clean_msg"
    ),
    .options.snow = opts1
  ) %dopar% {
    rcdts_key <- rcdts_mapping$rcdts[i]

    run_info <- c()
    for (pkg in c("janitor", "tidyr", "dplyr", "scales", "stringr", "rjson", "progress")) {
      suppressPackageStartupMessages(require(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))
    }
    name <- rcdts_mapping$Report[rcdts_mapping$rcdts == rcdts_key]

    tryCatch(
      {
        withCallingHandlers(
          {
            data <- dataList[[name]]
            data <- data[!is.na(names(data))]
            ## Figure Data
            # figure <- "fig1a"
            # figure <- "fig3c"
            # figure <- "fig4c.2"
            num_responses <- list(num_respondents = as.numeric(num_responses))
            for (figure in names(data)[grepl("fig", names(data))]) {
              print(figure)
              data[[figure]] <- cleanDataList_Fig(data[[figure]], figure, num_responses)
            }
            ## Table Data
            # table <- names(data)[grepl("tbl",names(data))][8]
            # table <- "tbl0"
            # table <- "tbl2c.2"
            for (table in names(data)[grepl("tbl", names(data))]) {
              data[[table]] <- cleanDataList_Table(data[[table]], grade_bands, name)
            }
            output <- list(data, run_info)
            names(output) <- c("data", "log")
            return(output)
          },
          warning = function(w) {
            run_info <<- append(run_info, paste0("**WARNING: Data Backend Iteration ", i, " | ", name, " (", rcdts_key, "):\n\n", clean_msg(w)))
            invokeRestart("muffleWarning")
          }
        )
      },
      error = function(e) {
        run_info <<- append(run_info, paste0("**ERROR: Data Backend Iteration ", i, " | ", name, " (", rcdts_key, "):\n\n", clean_msg(e)))
      }
    )
    output <- list(data, run_info)
    names(output) <- c("data", "log")
    return(output)
  }

  return(dataList)
}

# Function to perform any needed data cleaning steps on the text
cleanText <- function(rawText) {
  text <- rawText
  # Remove trailing spaces
  text$Indicator <- gsub(" +$", "", text$Indicator)
  text$Rating <- gsub(" +$", "", text$Rating)

  return(text)
}

# Function which puts all of the data in the proper format needed for the reports
# Parameters: rawData - A (wide) dataframe with each row corresponding to a report and each column corresponding to a variable
#            dataDict - A (long) data dictionary with each row corresponding to a particular variable within a particular figure
#            reportFilter - A regex string used to filter down the reports
# Returns: A named nested list where each outer element corresponds to a report. Each inner element contains a dataframe for a particular figure within the report

# rawData <- rawData_report_parts
# num_responses <-  staff_survey_respondents
prepData <- function(rawData, rawDataDict, reportFilter, grade_bands, num_responses, reports_to_skip) {
  # rawData <- rawData_report_parts
  # grade_bands <- school_grade_bands
  # Perform any additional data cleaning steps before reshaping the data
  if (exists("cleanData")) {
    data <- cleanData(rawData)
  } else {
    data <- rawData
  }

  if (exists("cleanDataDict")) {
    dataDict <- cleanDataDict(rawDataDict)
  } else {
    dataDict <- rawDataDict
  }

  # If no filter specified, run on all schools
  if (reportFilter == "" | is.na(reportFilter)) {
    reportFilter <- "."
  }
  # Filter the data down to the specified reports and pivot the data to a long format
  dataLong <- data %>%
    filter(grepl(reportFilter, data$Report, ignore.case = TRUE)) %>%
    filter(!grepl(reports_to_skip, Report, ignore.case = TRUE)) %>%
    pivot_longer(-c(Report, rcdts)) %>%
    rename("Variable" = "name")

  # Create the list of reports
  #currReport <- unique(dataLong$Report)[1]
  reportList <- lapply(unique(dataLong$Report), function(currReport) {
    # Filter down to a single report
    subset <- dataLong %>% filter(Report %in% currReport)
    # Merge into the data dictionary
    test <- dataDict %>%
      left_join(subset, by = c("Variable")) %>%
      relocate("Report", .before = "Figure_num")
    # test <- test %>%
    #   filter(!(Group %in% classBandsNotInReport))
    # Split into a list of dataframes for each figure, dropping columns that are entirely NA
    essentials_col <- c("value")
    dataList <- lapply(unique(test$Figure_num), function(fig) {
      return(test %>% filter(Figure_num %in% fig) %>% select(all_of(essentials_col), where(~ !all(is.na(.)) | all(names(.) == "Report"))))
    })
    # Add names to the list corresponding to the figure numbers
    names(dataList) <- unique(test$Figure_num)
    return(dataList)
  })
  # Add names to the list corresponding to the report names
  names(reportList) <- unique(dataLong$Report)
  if (exists("cleanDataList")) {
    num_responses_df <- as.data.frame(t(num_responses)) # Transpose to make it a proper data frame
    num_responses <- num_responses_df$num_respondents
    reportList <- cleanDataList(reportList, grade_bands, num_responses, distinct(rawData[, c("rcdts", "Report")]))
    # Add names to the list corresponding to the report names
    names(reportList) <- unique(dataLong$Report)
  }

  return(reportList)
}

# Function which puts all of the data in the proper format needed for the reports (reshaping/filtering)
prepText <- function(rawText) {
  if (exists("cleanText")) {
    text <- cleanText(rawText)
  } else {
    text <- rawText
  }

  # stuff goes here
  return(text)
}

prep_staff_survey_response <- function(data_string, compute_total = TRUE) {
  # Replace single quotes with double quotes to make it a valid JSON string
  json_str <- gsub("'", "\"", data_string)

  # Parse the JSON string
  parsed_list <- fromJSON(json_str)

  # Convert the list to a data frame
  df <- as.data.frame(parsed_list)

  # Transpose the data frame since we want columns, not rows
  df <- t(df)

  # Convert row names to a column
  df <- data.frame(Response = rownames(df), Count = unlist(df, use.names = FALSE))

  # Calculate the total count if compute_total is TRUE
  if (compute_total) {
    total_count <- sum(df$Count)
    # Convert counts to percentages
    df$Count <- (df$Count / total_count)
  }

  # Replace periods with spaces in the 'Response' column
  df$Response <- gsub("\\.", " ", df$Response)

  # Convert the 'Count' column to numeric
  numeric_values <- as.numeric(df$Count)

  return(numeric_values)
}

cleanup_school_names <- function(df, column_name) {
  df[[column_name]] <- gsub("Elem ", "Elementary ", df[[column_name]])
  df[[column_name]] <- gsub("Elem$", "Elementary", df[[column_name]])
  df[[column_name]] <- gsub("Elem-", "Elementary-", df[[column_name]])
  df[[column_name]] <- gsub("Sch ", "School ", df[[column_name]])
  df[[column_name]] <- gsub("Sch-", "School-", df[[column_name]])
  df[[column_name]] <- gsub("Schl-", "School-", df[[column_name]])
  df[[column_name]] <- gsub("Cntr", "Center-", df[[column_name]])
  df[[column_name]] <- gsub("Cntr ", "Center ", df[[column_name]])
  df[[column_name]] <- gsub("/", " ", df[[column_name]])
  df[[column_name]] <- gsub(" -", "-", df[[column_name]])
  df[[column_name]] <- gsub("\\.", "", df[[column_name]])
  df[[column_name]] <- gsub("--", "-", df[[column_name]])
  df[[column_name]] <- gsub("Sr", "Senior", df[[column_name]])
  df[[column_name]] <- gsub("Jr", "Junior", df[[column_name]])
  df[[column_name]] <- gsub("#", "", df[[column_name]])
  df[[column_name]] <- gsub(" HS ", " High School ", df[[column_name]])
  df[[column_name]] <- gsub("HS-", "High School-", df[[column_name]])
  df[[column_name]] <- gsub("Ctr", "Center", df[[column_name]])
  df[[column_name]] <- gsub("Education", "Ed", df[[column_name]])
  df[[column_name]] <- gsub("&", "and", df[[column_name]])
  df[[column_name]] <- gsub("  ", " ", df[[column_name]])
  df[[column_name]] <- gsub("CPS", "City of Chicago SD 299", df[[column_name]])
  # df[[column_name]]<- gsub("Ronald D O Neal-", "Ronald D. O'Neil Elementary School-", df[[column_name]])

  df[[column_name]] <- gsub("J. L.", "J L", df[[column_name]])
  df[[column_name]] <- gsub("Madison School- Dixon USD 170", "Madison Elementary School- Dixon USD 170", df[[column_name]])
  df[[column_name]] <- gsub("Chopin Elementary School- CPS", "Chopin Elementary School- City of Chicago SD 299", df[[column_name]])
  df[[column_name]] <- gsub("Lewis Lemon Elementary School- Rockford SD 205", "Lewis Lemon Elementary- Rockford SD 205", df[[column_name]])
  df[[column_name]] <- gsub("Rolling Green Elementary School", "Rolling Green", df[[column_name]])
  df[[column_name]] <- gsub("Kellman Corporate Community Elementary School", "Kellman Corporate Community Elem", df[[column_name]])
  # Modify to keep only the first occurrence of '-'
  df[[column_name]] <- gsub("Perspectives Chtr-  IIT Campus", "Perspectives Chtr IIT Campus", df[[column_name]])
  df[[column_name]] <- gsub("Rockford Envrnmntl Science Acad", "Rockford Environmental Science Academy", df[[column_name]])
  df[[column_name]] <- gsub("Reavis Elementary Math & Science Specialty School", "Reavis Elementary Math and Science Specialty School", df[[column_name]])
  df[[column_name]] <- gsub("Reavis Elementary Math and Sci Spec School", "Reavis Elementary Math and Science Specialty School", df[[column_name]])
  df[[column_name]] <- gsub("Ronald D O Neal- SD U-46", "Ronald D. O'Neal Elementary School- SD U-46", df[[column_name]])
  df[[column_name]] <- gsub("Adam Clayton Powell, Junior, Paideia Academy- City of Chicago SD 299", "Adam Clayton Powell, Jr., Paideia Academy- City of Chicago SD 299", df[[column_name]])
  # df[[column_name]]<- gsub("Hay Elementary Community Academy- City of Chicago SD 299", "John Hay Elementary Community Academy- City of Chicago SD 299", df[[column_name]])
  return(df)
}

cleanup_gradebands <- function(df, column_name) {
  df[[column_name]] <- gsub("Jan", 1, df[[column_name]])
  df[[column_name]] <- gsub("Feb", 2, df[[column_name]])
  df[[column_name]] <- gsub("Mar", 3, df[[column_name]])
  df[[column_name]] <- gsub("Apr", 4, df[[column_name]])
  df[[column_name]] <- gsub("May", 5, df[[column_name]])
  df[[column_name]] <- gsub("Jun", 6, df[[column_name]])
  df[[column_name]] <- gsub("Jul", 7, df[[column_name]])
  df[[column_name]] <- gsub("Aug", 8, df[[column_name]])
  df[[column_name]] <- gsub("Sep", 9, df[[column_name]])
  df[[column_name]] <- gsub("Oct", 10, df[[column_name]])
  df[[column_name]] <- gsub("Nov", 11, df[[column_name]])
  df[[column_name]] <- gsub("Dec", 12, df[[column_name]])

  return(df)
}

fix_special_characters_string <- function(input_string) {
  # Replace '%' with '\%'
  fixed_string <- gsub("%", "\\\\% ", input_string)

  # Replace '&' with '\&'
  fixed_string <- gsub("&", "\\\\&", fixed_string)

  # Replace "'" with "''"
  fixed_string <- gsub("'", "''", fixed_string)

  # Replace "\r\n" with ""
  fixed_string <- gsub("\r\n", "", fixed_string)

  return(fixed_string)
}

fix_special_characters <- function(df, column_name) {
  # Replace '%' with '\%'
  df[[column_name]] <- gsub("\\\\", "", df[[column_name]])

  # Replace '&' with '\&'
  df[[column_name]] <- gsub("&", "\\\\&", df[[column_name]])

  # Replace '&' with '\&'
  df[[column_name]] <- gsub("#", "\\\\#", df[[column_name]])

  # Replace '&' with '\&'
  # df[[column_name]] <- gsub("\\\\…", "...", df[[column_name]])

  # Replace "_" with "\_"
  df[[column_name]] <- gsub("_", "\\\\_", df[[column_name]])

  # Replace '%' with '\%'
  df[[column_name]] <- gsub("%", "\\\\%", df[[column_name]])

  # Replace '%' with '\%'
  df[[column_name]] <- gsub("\\$", "\\\\$", df[[column_name]])

  # Replace '…' with '...'
  df[[column_name]] <- gsub("\u2026", "\\\\ldots", df[[column_name]])

  # Replace '–' with -
  df[[column_name]] <- gsub("\u2212", "--", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u2013", "--", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u2012", "--", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u2026", "...", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u2014", "--", df[[column_name]], fixed = TRUE)
  # Replace "'" with "''"
  df[[column_name]] <- gsub("'", "'", df[[column_name]])

  df[[column_name]] <- gsub("\r\n", "", df[[column_name]])

  df[[column_name]] <- gsub("\u2019", "'", df[[column_name]], fixed = TRUE)

  df[[column_name]] <- gsub("\u201C", "``", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u201D", '"', df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u00A0", " ", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("?", "?", df[[column_name]], fixed = TRUE)
  df[[column_name]] <- gsub("\u00F1", "\\~n", df[[column_name]], fixed = TRUE)

  return(df)
}


fix_quotes <- function(df, column_name) {
  for (i in 1:nrow(df)) {
    text <- df[[column_name]][i]
    occ <- gregexpr('"', text)[[1]]
    offset <- 0
    for (j in 1:length(occ)) {
      if (j %% 2 == 1) {
        char_num <- occ[j] + offset
        temp_string <- substr(text, char_num, char_num)
        temp_string <- str_replace(temp_string, '"', "``")
        text <- paste0(substr(text, 1, char_num - 1), temp_string, substr(text, char_num + 1, nchar(text)))
        offset <- offset + 1 # Update offset
      }
    }
    df[[column_name]][i] <- text
  }
  return(df)
}






fix_ratings_spelling <- function(df, column_name) {
  correct_values <- c("Initial", "Emerging", "Established", "Robust")

  # Convert the column to lowercase to make comparison case-insensitive
  df[[column_name]] <- tolower(df[[column_name]])

  df[[column_name]] <- gsub("robust and sustainable", "Robust", df[[column_name]], fixed = TRUE)

  # Find misspelled values and replace them with the nearest correct match
  df[[column_name]] <- sapply(df[[column_name]], function(x) {
    if (!is.na(x) && x != "") {
      distances <- adist(x, correct_values)
      closest_match <- correct_values[which.min(distances)]
      return(closest_match)
    } else {
      return(x)
    }
  })
  return(df)
}

remove_single_quotes <- function(input_string) {
  # Use gsub to replace single quotes with an empty string
  result_string <- gsub("'", " ", input_string)
  return(result_string)
}
