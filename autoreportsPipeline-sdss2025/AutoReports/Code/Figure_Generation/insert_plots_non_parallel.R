source(file.path("Code", "Figure_Generation", "plotting_functions.R"))

# Functions to create the image files for each figure. 'scale' is used to change the size of the file being saved, where scale=2
# means the file being saved is twice the specified size. Note that sizing of certain ggplot elements will be impacted by the scale
# (most things with a "size" attribute will not scale up to larger save sizes)
# I would recommend having a scale larger than 1 for good image quality, and if using file types other than pdf, I would recommend
# a scale larger than 4
# The preset width and height are just starting points to work off of. These are the final size of the image in the report

# add_table_graphic <- function(data, width = 400, height = 200, units = "px", scale = 2, text_scalar = 1, bg = "transparent", anchor = "north west", xshift = 0, yshift = 0, alt = "", single_page_version = FALSE, report_name = "") {
#   filename <- paste0(report_name, "_table_graphic_", data$Figure_num[1], ".png")

#   plt <- create_table_graphic(data, text_scalar)

#   if (units == "pt") {
#     if (single_page_version == TRUE) {
#       ggsave(file.path("..", "..", "Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = "px", bg = bg, dpi = 400)
#     } else {
#       ggsave(file.path("Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = "px", bg = bg, dpi = 400)
#     }
#   } else {
#     if (single_page_version == TRUE) {
#       ggsave(file.path("..", "..", "Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = units, bg = bg, dpi = 400)
#     } else {
#       ggsave(file.path("Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = units, bg = bg, dpi = 400)
#     }
#   }
#   cat(paste0("\\node[anchor=", anchor, ", xshift=", xshift, ", yshift=", yshift, "] at (current page.", anchor, ") {", wrap508(tag = "Figure", alt = alt, width = paste0(width, units), height = paste0(height, units), file.path("Data", "Temp", report_name, filename)), "};\n"))
# }

# add_survey_response_graphic <- function(data, width = 510, height = 160, units = "px", scale = 10, text_scalar = 1, bg = "transparent", anchor = "north west", xshift = 35, yshift = -60, alt = "", single_page_version = FALSE, report_name = "") {
#   filename <- paste0(report_name, "_survey_response_graphic_", data$Figure_num[1], ".png")

#   if (length(unique(data$Group)) == 2) {
#     yshift <- yshift - 36
#   } else if (length(unique(data$Group)) == 3) {
#     yshift <- yshift - 73
#   } else if (length(unique(data$Group)) == 4) {
#     yshift <- yshift - 71
#     height <- height + 40
#   } else if (length(unique(data$Group)) == 5) {
#     yshift <- yshift - 66
#     height <- height + 90
#   } else if (length(unique(data$Group)) == 6) {
#     yshift <- yshift - 66
#     height <- height + 130
#   } else if (length(unique(data$Group)) == 7) {
#     yshift <- yshift - 61
#     height <- height + 180
#   } else if (length(unique(data$Group)) == 8) {
#     yshift <- yshift - 63
#     height <- height + 200
#   } else if (length(unique(data$Group)) == 9) {
#     yshift <- yshift - 63
#     height <- height + 225
#   } else if (length(unique(data$Group)) == 10) {
#     yshift <- yshift - 63
#     height <- height + 250
#   } else if (length(unique(data$Group)) == 11) {
#     yshift <- yshift - 63
#     height <- height + 275
#   } else if (length(unique(data$Group)) == 12) {
#     yshift <- yshift - 63
#     height <- height + 300
#   }

#   plt <- create_survey_response_graphic(data, text_scalar)

#   if (units == "pt") {
#     if (single_page_version == TRUE) {
#       ggsave(file.path("..", "..", "Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = "px", bg = bg, dpi = 400)
#     } else {
#       ggsave(file.path("Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = "px", bg = bg, dpi = 400)
#     }
#   } else {
#     if (single_page_version == TRUE) {
#       ggsave(file.path("..", "..", "Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = units, bg = bg, dpi = 400)
#     } else {
#       ggsave(file.path("Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = units, bg = bg, dpi = 400)
#     }
#   }

#   cat(paste0("\\node[anchor=", anchor, ", xshift=", xshift, ", yshift=", yshift, "] at (current page.", anchor, ") {", wrap508(tag = "Figure", alt = alt, width = paste0(width, units), height = paste0(height, units), file.path("Data", "Temp", report_name, filename)), "};\n"))
# }

add_question19_graphic <- function(data, width = 510, height = 120, units = "px", scale = 2, text_scalar = 1, bg = "transparent", anchor = "north west", xshift = 0, yshift = 0, alt = "", report_name = "") {
  print(report_name)
  filename <- paste0(report_name, "_q19_graphic_", data$Figure_num[1], ".png")

  plt <- create_question19_graphic(data, text_scalar)

  if (units == "pt") {
    ggsave(file.path("..", "..", "Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = "px", bg = bg, dpi = 400)
  } else {
    ggsave(file.path("..", "..", "Data", "Temp", report_name, filename), plot = plt, width = width * scale, height = height * scale, units = units, bg = bg, dpi = 400)
  }
  cat(paste0("\\node[anchor=", anchor, ", xshift=", xshift, ", yshift=", yshift, "] at (current page.", anchor, ") {", wrap508(tag = "Figure", alt = alt, width = paste0(width, units), height = paste0(height, units), file.path("Data", "Temp", report_name, filename)), "};\n"))
}


add_survey_response_legend <- function(xshift = 175, yshift = -140, options = c("Strongly Disagree", "Disagree", "Agree", "Strongly Agree", "No Response")) {
  if (all(c("Never", "Annually", "Twice Per Year", "Quarterly", "No Response") %in% options)) {
    xshift <- xshift + 23
    cat(paste0("\\draw[theblack, thin, fill=thegraphicdarkorange, anchor=north west] (", xshift + 30, "pt, ", yshift, "pt) rectangle (", xshift + 37, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 40, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[1], "};
\\draw[theblack, thin, fill=thegraphiclightorange, anchor=north west] (", xshift + 75, "pt, ", yshift, "pt) rectangle (", xshift + 82, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 85, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[2], "};
\\draw[theblack, thin, fill=thegraphiclightblue, anchor=north west] (", xshift + 135, "pt, ", yshift, "pt) rectangle (", xshift + 142, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 145, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[3], "};
\\draw[theblack, thin, fill=thegraphicdarkblue, anchor=north west] (", xshift + 220, "pt, ", yshift, "pt) rectangle (", xshift + 227, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 230, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[4], "};
\\draw[theblack, thin, fill=thedarkgrey, anchor=north west] (", xshift + 285, "pt, ", yshift, "pt) rectangle (", xshift + 292, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 295, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[5], "};"))
  } else {
    cat(paste0("\\draw[theblack, thin, fill=thegraphicdarkorange, anchor=north west] (", xshift, "pt, ", yshift, "pt) rectangle (", xshift + 7, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 10, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[1], "};
\\draw[theblack, thin, fill=thegraphiclightorange, anchor=north west] (", xshift + 105, "pt, ", yshift, "pt) rectangle (", xshift + 112, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 115, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[2], "};
\\draw[theblack, thin, fill=thegraphiclightblue, anchor=north west] (", xshift + 170, "pt, ", yshift, "pt) rectangle (", xshift + 177, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 180, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[3], "};
\\draw[theblack, thin, fill=thegraphicdarkblue, anchor=north west] (", xshift + 220, "pt, ", yshift, "pt) rectangle (", xshift + 227, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 230, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[4], "};
\\draw[theblack, thin, fill=thedarkgrey, anchor=north west] (", xshift + 310, "pt, ", yshift, "pt) rectangle (", xshift + 317, "pt, ", yshift - 7, "pt);
\\node[anchor=north west, xshift=", xshift + 320, ", yshift=", yshift - 7, "] at (current page.north west){\\fontsize{10}{10}\\selectfont ", options[5], "};"))
  }
}
