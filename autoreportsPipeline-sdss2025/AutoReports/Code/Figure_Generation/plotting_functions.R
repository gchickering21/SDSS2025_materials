# library(tidyverse)

create_table_graphic <- function(data, text_scalar = 1) {
  plt <- ggplot() +
    geom_col(aes(x = 1, y = c(20, 20, 20, 20, 20), fill = factor(c(20, 40, 60, 80, 100))), color = "black", linewidth = .2, width = .05) +
    geom_segment(aes(x = c(.94, .94, .94, .94), xend = c(1.06, 1.06, 1.06, 1.06), y = c(20, 40, 60, 80), yend = c(20, 40, 60, 80)), linewidth = .2) +
    geom_text(aes(x = 1.18, y = data$value + 1, label = "\u25C0"), family = "Lucida Sans Unicode", size = 8 * text_scalar, color = "#084f7e") +
    geom_text(aes(x = c(.55, .68, .64, .67, .55), y = c(10, 30, 50, 70, 90), label = c("Very Weak", "Weak", "Neutral", "Strong", "Very Strong")), size = 3 * text_scalar) +
    xlim(c(0, 2)) +
    scale_fill_manual(values = c("#176f9f", "#98c6e8", "#a2aaad", "#f9a871", "#eb6923")) +
    theme_void() +
    theme(legend.position = "none")

  return(plt)
}

add_newline_to_column <- function(column_data, width = 70) {
  # NOTE: Changing to str_wrap for more consistent line sizes (uses character count instead of word count)

  # Function to add newline characters after every 'width' characters (does not break up words)
  add_newline <- function(text) {
    text <- gsub('\n|<br>',' ',text) #Remove any manual breaks already present
    text <- str_wrap(text, width = width) #Add linebreaks
    text <- gsub("\n", "<br>", text) #Change to markdown syntax
    return(text)
    # words <- unlist(strsplit(text, "\\s+"))  # Split text into words
    # grouped_words <- split(words, ceiling(seq_along(words) / words_per_line))  # Group into chunks
    # paste(sapply(grouped_words, paste, collapse = " "), collapse = "<br>")  # Combine with newlines
  }
  
  # Apply the newline function to each element in the column
  transformed_column <- sapply(column_data, add_newline, USE.NAMES = FALSE)
  
  return(transformed_column)  # Return the modified column
}

create_survey_response_graphic <- function(data, text_scalar = 1) {
  # data <- reportData[['fig1d.2']]
  
  palette_agreement_level <- c(
    "Strongly Disagree" = "#E96A24",
    "Disagree" = "#F9A872",
    "Agree" = "#98C7E8",
    "Strongly Agree" = "#006E9F",
    "No Response" = "#a2aaad"
  )
  
  palette_response_frequency <- c(
    "Never" = "#E96A24",
    "Annually" = "#F9A872",
    "Semi-annually" = "#98C7E8",
    "Quarterly or more" = "#006E9F",
    "No Response" = "#a2aaad"
  )
  
  palette_response_aggregate <- c(
    "Less than monthly" = "#E96A24",
    "Monthly" = "#F9A872",
    "Multiple times per month" = "#98C7E8",
    "Weekly or more" = "#006E9F",
    "No Response" = "#a2aaad"
  )
  
  
  #Combine palettes (removing the duplicate "no response")
  combined_palette <- c(palette_agreement_level[-5],palette_response_frequency[-5],palette_response_aggregate)
  
  
  # Bold headers and convert line breaks to markdown syntax
  data$Group[grepl("\\.\\.\\.|:", data$Group)] <- paste0("<b>", data$Group[grepl("\\.\\.\\.|:", data$Group)], "</b>")
  data$Group <- gsub("\n", "<br>", data$Group)
  
  data$Subgroup <- gsub("<U+2019>", "'", data$Subgroup)
  
  # Hide labels for categories that are 0%
  data <- data %>% mutate(
    text_label = ifelse(text_label == "0%", "", text_label),
    stagger = ifelse(value < .065 & !is.na(text_label), .35, 0),
    color = (Subgroup %in% c("Strongly Agree", "Quarterly or more", "Weekly or more")) & (stagger == 0)
  )
  # mark overlaps
  data$overlap <- FALSE
  for (group in data$Group) {
    group_data <- data[data$Group == group, ]
    overlaps <- get_consecutive(group_data$stagger != 0)
    data[data$Group == group, "overlap"] <- overlaps
  }
  
  # alternate stagger direction for overlaps
  data <- data %>%
    group_by(Group, overlap) %>%
    mutate(stagger = ifelse(cumsum(overlap == TRUE) %% 2 == 0 & overlap == TRUE, -.35, stagger)) %>%
    ungroup()
  
  data$Group <- gsub("<U+2019>", "'", data$Group)
  data$text_label <- gsub("<U+2019>", "'", data$text_label)
  
  
  data$Subgroup <- factor(data$Subgroup,levels=rev(names(combined_palette)))
  
  data$Group <- add_newline_to_column(data$Group) 
  
  axis_limits <- c(0, length(unique(data$Group)) + 1)
  
  plt <- ggplot(data) +
    geom_col(aes(x = numeric_group, y = value, fill = Subgroup), color = "black", linewidth = 0.2, width = .4) +
    geom_text(aes(x = numeric_group + stagger, y = text_location, color = color, label = text_label), size = 8 * text_scalar, show.legend=F) +
    coord_flip() +
    scale_fill_manual(values = combined_palette) +
    scale_color_manual(values = c("FALSE" = "black", "TRUE" = "white")) +
    scale_x_continuous(limits = axis_limits, breaks = 1:length(unique(data$Group)), labels = rev(unique(data$Group))) +
    theme_void() +
    guides(fill = guide_legend(reverse=TRUE, byrow=TRUE)) +
    theme(
      legend.position = "top", #Can specify exact coordinates to more finely adjust this (currently is centered above the bars, as the survey questions are axis labels)
      legend.direction = "horizontal",
      legend.justification = c(1, 0),
      legend.title = element_blank(),
      legend.text = element_markdown(size = 28 * text_scalar, margin=margin(t=2,b=-2,r=10)),
      legend.key.size = unit(28 * text_scalar,"pt"),
      legend.box.spacing = unit(-50, "pt"),
      legend.box.margin = margin(t = 5, r = 5, b = 5, l=5),
      plot.margin = margin(t = 5, r = 5, b = -75, l = 25),
      axis.text.y = element_markdown(size = 28 * text_scalar, hjust = 1)
    )
  
  return(plt)
}
create_question19_graphic <- function(data, text_scalar = 1) {
  data <- reportData[["fig4c.2"]]


  ggplot(data) +
    # geom_label(aes(x=Subgroup, y=.35, label=text_label), size=18*text_scalar, label.size=0, fill="#a2aaad", label.padding=unit(10,'pt')) +
    geom_text(aes(x = Subgroup, y = .375, label = text_label), size = 12 * text_scalar) +
    ylim(c(0, 1)) +
    labs(title = data$Group[1]) +
    theme_void() +
    theme(
      legend.position = "none",
      axis.text.x = element_markdown( size = 18 * text_scalar, margin = margin(t = -40, b = 40)),
      plot.title = element_markdown(size = 18 * text_scalar, margin = margin(t = 40, b = -40, l = 35))
    )
}

# used to identify/mark overlapping labels
get_consecutive <- function(vec) {
  output_vec <- rep(FALSE, length(vec))
  true_vec <- which(vec)
  runs <- sapply(1:length(true_vec), function(i) {
    if (length(true_vec) <= 1) {
      return(FALSE)
    }
    if (i == 1) {
      if ((true_vec[i + 1] - true_vec[i]) == 1) {
        return(TRUE)
      } else {
        return(FALSE)
      }
    }
    if (i == length(true_vec)) {
      if ((true_vec[i] - true_vec[i - 1]) == 1) {
        return(TRUE)
      } else {
        return(FALSE)
      }
    }
    if ((true_vec[i + 1] - true_vec[i]) == 1 | (true_vec[i] - true_vec[i - 1]) == 1) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  })
  true_vec <- true_vec[runs]
  output_vec[true_vec] <- TRUE
  return(output_vec)
}
