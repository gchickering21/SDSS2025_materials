add_turnaround_indicator_table <- function(data, xshift, yshift) {
  col_layout <- "Iwl{8.8cm}Iwc{2cm}Iwc{2cm}Iwc{2cm}Iwc{2cm}I"
  set_params(list(dfont_size = c(9, 10), hfont_size = c(9, 10), dfont_color = "tabledarkblue", dbold = TRUE, row_sep = "\\arrayrulecolor{thegrey}\\hline"))

  body <- paste0(create_rows(c("Needs Assessment Indicator", "Initial", "Emerging", "Established", "Robust"), row_color = "tabledarkblue", hfont_color = "thewhite", hfont_size = 11, hfont_family = "extrabold", cell_types = "TH", hscope = c("both", "col", "col", "col", "col")))

  curr_rowgroup <- ""
  # tracks which rows have headers that need vertical lines to be covered up
  header_rows <- c()
  header_colors <- c()
  # A running count of header rows to aid with calculations
  j <- 0
  # i <- 1
  for (i in 1:nrow(data)) {
    rowgroup <- gsub(".+ - ", "", data$Figure_name[i])
    # Add header row if in a new section
    if (rowgroup != curr_rowgroup) {
      curr_rowgroup <- rowgroup
      if (grepl("1. ", curr_rowgroup)) {
        row_color <- "thelightblue"
      } else if (grepl("2. ", curr_rowgroup)) {
        row_color <- "thelightgreen"
      } else if (grepl("3. ", curr_rowgroup)) {
        row_color <- "thelightpink"
      } else {
        row_color <- "thelightorange"
      }

      body <- paste0(body, create_rows(curr_rowgroup, row_color = row_color, hfont_family = "extrabold", hfont_size = 10))
      header_rows <- c(header_rows, i + j + 1)
      header_colors <- c(header_colors, row_color)
      j <- j + 1
    }
    if (i != nrow(data)) {
      body <- paste0(body, create_rows(data[i, ] %>% select(-Report, -Figure_num, -Figure_name, -Variable, -Subgroup)))
    } else {
      body <- paste0(body, create_rows(data[i, ] %>% select(-Report, -Figure_num, -Figure_name, -Variable, -Subgroup), sep_at_end = FALSE, newline = FALSE))
    }
  }

  code_after <- paste0(
    c(
      "\\tikz \\draw [tabledarkblue] (1-|1) -- (2-|1) ;", # Fill in the border on left and right of row one to line up with rest of table
      "\\tikz \\draw [tabledarkblue] (1-|last) -- (2-|last) ;",
      "\\tikz \\draw [line width=.2em, theblue] (2-|1) -- (2-|last) ;", # Add thick blue line under header

      "\\tikz \\draw [line width=.1em, tabledarkblue] (3-|1) -- (3-|last) ;", # Add dark blue lines around header rows
      paste0(
        "\\tikz \\draw [line width=.1em, tabledarkblue] (", header_rows[-1], "-|1) -- (", header_rows[-1], "-|last) ;\n",
        "\\tikz \\draw [line width=.1em, tabledarkblue] (", header_rows[-1] + 1, "-|1) -- (", header_rows[-1] + 1, "-|last) ;\n"
      ),
      "\\tikz \\draw [line width=.1em, tabledarkblue] (last-|1) -- (last-|last) ;"
    ), # Add dark blue line at bottom of table
    collapse = "\n"
  )

  add_tagged_table(
    xshift = xshift, yshift = yshift, col_layout = col_layout, body = body, code_after = code_after, arraystretch = 1.9,
    hide_lines = list(rows = header_rows, ncol = 5, color = header_colors)
  )
}


add_grade_table <- function(data, classBand, xshift, yshift) {
  # Reshape data from long to wide
  # table_data <- data %>% select(group, subgroup, value) %>% pivot_wider(names_from=subgroup, values_from=value)

  col_layout <- "Iwl{3.56cm}*{9}{Iwc{1.2cm}}I"
  set_params(list(dfont_size = 10.5, hfont_size = 10, row_sep = "\\arrayrulecolor{thegrey}\\hline"))

  body <- paste0(
    "\\rowcolor{tabledarkblue}\\tagstructbegin{tag=TR}\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[l, fill=tabledarkblue]{2-1}{}\\tagmcend\\tagstructend\n & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-2}{\\textcolor{thewhite}{\\extrabold{Low Range}}}\\tagmcend\\tagstructend\n & & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-3}{\\textcolor{thewhite}{\\extrabold{Middle Range}}}\\tagmcend\\tagstructend\n & & & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-2}{\\textcolor{thewhite}{\\extrabold{High Range}}}\\tagmcend\\tagstructend\n & & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\textcolor{thewhite}{\\extrabold{\\textit{n}}}\\tagmcend\\tagstructend\n & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\textcolor{thewhite}{\\extrabold{Average}}\\tagmcend\\tagstructend\n\n \\tagstructend\n\\\\ \n",
    create_rows(c("\\textcolor{thewhite}{Grade Band}", "1", "2", "3", "4", "5", "6", "7", "", ""), cell_types = "TH", hscope = "col", row_color = "tabledarkblue", hfont_color = "thewhite", hfont_family = "extrabold")
  )


  for (i in 1:length(classBand)) {
    if (i != length(classBand)) {
      body <- paste0(body, create_rows(data[i, ] %>% select(-Report, -Figure_num, -Figure_name, -Variable)))
    } else {
      body <- paste0(body, create_rows(data[i, ] %>% select(-Report, -Figure_num, -Figure_name, -Variable), newline = FALSE))
    }
  }

  code_after <- paste0(
    c(
      "\\tikz \\draw [thegrey] (2-|2) -- (2-|last) ;", # Add the line under the first row
      "\\tikz \\draw [tabledarkblue] (1-|1) -- (3-|1) ;", # Fill in the border on left and right of row one to line up with rest of table
      "\\tikz \\draw [tabledarkblue] (1-|last) -- (3-|last) ;",
      "\\tikz \\draw [line width=.2em, theblue] (3-|1) -- (3-|last) ;", # Add thick blue line under header
      "\\tikz \\draw [line width=.1em, tabledarkblue] (last-|1) -- (last-|last) ;"
    ), # Add dark blue line at bottom of table
    collapse = "\n"
  )

  # cat(paste0("\\draw[theblack, fill=thelightblue, thin] (",xshift,"pt+135pt,",yshift,"pt+27pt) rectangle (",xshift,"pt+390pt,",yshift,"pt+5pt);\n"))
  # cat(paste0("\\node[anchor=north west,xshift=",xshift,"+140,yshift=",yshift,"+16] at (current page.north west) {\\textcolor{tabledarkblue}{\\fontsize{12}{14}\\selectfont{\\textbf{Concept Development School Average$^*$: 4.5}}}};\n"))
  add_tagged_table(xshift = xshift, yshift = yshift, col_layout = col_layout, body = body, code_after = code_after, arraystretch = 1.25)

  spacing <- 35 + 15 * nrow(data)
  cat(paste0(
    "\\node[anchor=north west,xshift=", xshift, ",yshift=", yshift, "-", spacing, ", align=left, text width=7.25in, font=\\footnotesize] at (current page.north west) {\\raggedright$^*$The school average is a weighted average calculation of the observation scores. $\\text{Weighted Average} = \\frac{\\sum \\text{Rating} \\times \\text{Frequency}}{\\sum \\text{Frequency}}$.\\newline",
    "};\n"
  ))
}

add_grade_table2 <- function(data, classBand, xshift, yshift) {
  # Reshape data from long to wide
  # table_data <- data %>% select(group, subgroup, value) %>% pivot_wider(names_from=subgroup, values_from=value)

  col_layout <- "Iwl{3.56cm}*{9}{Iwc{1.2cm}}I"
  set_params(list(dfont_size = 10.5, hfont_size = 10, row_sep = "\\arrayrulecolor{thegrey}\\hline"))

  body <- paste0(
    "\\rowcolor{tabledarkblue}\\tagstructbegin{tag=TR}\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[l, fill=tabledarkblue]{2-1}{}\\tagmcend\\tagstructend\n & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-2}{\\textcolor{thewhite}{\\extrabold{High Range}}}\\tagmcend\\tagstructend\n & & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-3}{\\textcolor{thewhite}{\\extrabold{Middle Range}}}\\tagmcend\\tagstructend\n & & & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-2}{\\textcolor{thewhite}{\\extrabold{Low Range}}}\\tagmcend\\tagstructend\n & & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\textcolor{thewhite}{\\extrabold{\\textit{n}}}\\tagmcend\\tagstructend\n & ",
    "\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\textcolor{thewhite}{\\extrabold{Average}}\\tagmcend\\tagstructend\n\n \\tagstructend\n\\\\ \n",
    create_rows(c("\\textcolor{thewhite}{Grade Band}", "1", "2", "3", "4", "5", "6", "7", "", ""), cell_types = "TH", hscope = "col", row_color = "tabledarkblue", hfont_color = "thewhite", hfont_family = "extrabold")
  )


  for (i in 1:length(classBand)) {
    if (i != length(classBand)) {
      body <- paste0(body, create_rows(data[i, ] %>% select(-Report, -Figure_num, -Figure_name, -Variable)))
    } else {
      body <- paste0(body, create_rows(data[i, ] %>% select(-Report, -Figure_num, -Figure_name, -Variable), newline = FALSE))
    }
  }

  code_after <- paste0(
    c(
      "\\tikz \\draw [thegrey] (2-|2) -- (2-|last) ;", # Add the line under the first row
      "\\tikz \\draw [tabledarkblue] (1-|1) -- (3-|1) ;", # Fill in the border on left and right of row one to line up with rest of table
      "\\tikz \\draw [tabledarkblue] (1-|last) -- (3-|last) ;",
      "\\tikz \\draw [line width=.2em, theblue] (3-|1) -- (3-|last) ;", # Add thick blue line under header
      "\\tikz \\draw [line width=.1em, tabledarkblue] (last-|1) -- (last-|last) ;"
    ), # Add dark blue line at bottom of table
    collapse = "\n"
  )

  # cat(paste0("\\draw[theblack, fill=thelightblue, thin] (",xshift,"pt+135pt,",yshift,"pt+27pt) rectangle (",xshift,"pt+390pt,",yshift,"pt+5pt);\n"))
  # cat(paste0("\\node[anchor=north west,xshift=",xshift,"+140,yshift=",yshift,"+16] at (current page.north west) {\\textcolor{tabledarkblue}{\\fontsize{12}{14}\\selectfont{\\textbf{Concept Development School Average$^*$: 4.5}}}};\n"))
  add_tagged_table(xshift = xshift, yshift = yshift, col_layout = col_layout, body = body, code_after = code_after, arraystretch = 1.25)

  spacing <- 35 + 15 * nrow(data)
  cat(paste0(
    "\\node[anchor=north west,xshift=", xshift, ",yshift=", yshift, "-", spacing, ", align=left, text width=7.25in, font=\\footnotesize] at (current page.north west) {\\raggedright$^*$The school average is a weighted average calculation of the observation scores. $\\text{Weighted Average} = \\frac{\\sum \\text{Rating} \\times \\text{Frequency}}{\\sum \\text{Frequency}}$.\\newline",
    "};\n"
  ))
}

add_5essentials_table <- function(data, xshift, yshift) {
  col_layout <- "Iwl{7cm}Iwc{2.5cm}Iwc{2.5cm}I"
  set_params(list(dfont_size = 10, hfont_size = 10, row_sep = "\\arrayrulecolor{thegrey}\\hline"))

  body <- paste0(
    "\\tagstructbegin{tag=TR}\n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[l, fill=tabledarkblue]{2-1}{\\extrabold\\textcolor{thewhite}{\\fontsize{11}{12}\\selectfont{THE 5ESSENTIALS}}}\\tagmcend\\tagstructend\n & \n\\tagstructbegin{tag=TH,attribute=TH-col}\\tagmcbegin{tag=TH}\n\\Block[fill=tabledarkblue]{1-2}{\\extrabold\\textcolor{thewhite}{\\fontsize{10}{11}\\selectfont{PERFORMANCE}}}\\tagmcend\\tagstructend\n & \n \\tagstructend\n\\\\ \n",
    create_rows(c(" ", "Score", "Rating"), cell_types = "TH", hscope = "col", row_color = "tabledarkblue", hfont_color = "thewhite", hfont_family = "extrabold")
  )
  curr_rowgroup <- ""
  # tracks which rows have headers that need vertical lines to be covered up
  header_rows <- c()
  # tracks how many header rows were previously made to aid with calculations
  j <- 0
  for (i in 1:nrow(data)) {
    rowgroup <- gsub(".+ - ", "", data$Figure_name[i])
    if (rowgroup != curr_rowgroup) {
      curr_rowgroup <- rowgroup
      body <- paste0(body, create_rows(curr_rowgroup, hfont_family = "extrabold", row_color = "thewhite"))
      header_rows <- c(header_rows, i + j + 2)
      j <- j + 1
    }
    if (i != nrow(data)) {
      body <- paste0(body, create_rows(data[i, c("Group", "Score", "Rating")], row_color = "thewhite"))
    } else {
      body <- paste0(body, create_rows(data[i, c("Group", "Score", "Rating")], row_color = "thewhite", newline = FALSE))
    }
  }
  code_after <- paste0(
    c(
      "\\tikz \\draw [thegrey] (2-|2) -- (2-|4) ;", # Add the line under "PERFORMANCE"
      "\\tikz \\draw [tabledarkblue] (1-|1) -- (3-|1) ;", # Fill in the border on left and right of row one to line up with rest of table
      "\\tikz \\draw [tabledarkblue] (1-|last) -- (3-|last) ;",
      "\\tikz \\draw [line width=.1em, tabledarkblue] (last-|1) -- (last-|last) ;"
    ), # Add dark blue line at bottom of table
    collapse = "\n"
  )
  add_tagged_table(xshift = xshift, yshift = yshift, col_layout = col_layout, body = body, code_after = code_after, hide_lines = list(rows = header_rows, ncol = 3))
}


add_rubric_table <- function(xshift, yshift) {
  col_layout <- "I *4{>{\\raggedright\\arraybackslash}p{4.3cm}I}"
  set_params(list(dfont_size = c(10, 12), hfont_color = "thewhite", hfont_size = c(11, 13), hfont_family = "extrabold"))

  body <- paste0(
    create_rows(c("Initial", "Emerging", "Established", "Robust"), row_color = "tabledarkblue", cell_types = "TH", hscope = "col", hprefix = "\\Block[c]{1-1}{", hsuffix = "}"),
    create_rows(c(
      "Evidence suggests that necessary organizational practices, structures, or processes are nonexistent or are not yet fully effective.",
      "Evidence suggests that few necessary organizational practices, structures or processes are in place, that these are only in initial stages of development, or concentrated in a small segment of the school, such as the leadership team.",
      "Evidence suggests that some necessary organizational practices, structures, or processes are in place and are implemented effectively. However, key systems are not yet implemented schoolwide for all relevant teachers and students.",
      "Evidence suggests that necessary organizational practices, structures, or processes are in place and are implemented effectively for all or nearly all relevant teachers and students."
    ), cell_types = "TD", newline = FALSE)
  )

  code_after <- paste0(
    c(
      "\\tikz \\draw [tabledarkblue] (1-|1) -- (2-|1) ;", # Fill in the border on left and right of row one to line up with rest of table
      "\\tikz \\draw [tabledarkblue] (1-|last) -- (2-|last) ;",
      "\\tikz \\draw [line width=.2em, theblue] (2-|1) -- (2-|last) ;", # Add thick blue line under header
      "\\tikz \\draw [line width=.1em, tabledarkblue] (last-|1) -- (last-|last) ;"
    ), # Add dark blue line at bottom of table
    collapse = "\n"
  )

  add_tagged_table(xshift = xshift, yshift = yshift, col_layout = col_layout, body = body, code_after = code_after)
}


add_indicator_header <- function(curr_indicator, xshift, yshift) {
  col_layout <- "*{4}{wc{4.2cm}}"
  indicators <- c("Initial", "Emerging", "Established", "Robust")
  if (!is.na(curr_indicator)) {
    indicators[indicators == curr_indicator] <- paste0("\\Block[fill=tabledarkblue]{1-1}{\\extrabold\\textcolor{thewhite}{", indicators[indicators == curr_indicator], "}}")
  }

  body <- paste0(
    "\\rowcolor{tabledarkblue}\\tagstructbegin{tag=TR}\n\\tagstructbegin{tag=TH,attribute=TH-both}\\tagmcbegin{tag=TH}\n\\Block[c, fill=tabledarkblue]{1-4}{\\extrabold\\textcolor{thewhite}{\\fontsize{11}{12}\\selectfont{\\centering Rating Description from the 2023-24 Illinois Needs Assessment Implementation Continuum}}}\\tagmcend\\tagstructend\n \\tagstructend\n\\\\ \n",
    create_rows(indicators, cell_types = "TH", hscope = "col", newline = FALSE)
  )

  code_after <- paste0(
    c(
      "\\tikz \\draw [tabledarkblue] (1-|1) -- (2-|1) ;", # Fill in the border on left and right of row one to line up with rest of table
      "\\tikz \\draw [tabledarkblue] (1-|last) -- (2-|last) ;",
      "\\tikz \\draw [line width=.25em, theblue] (1-|1) -- (1-|last) ;", # Add blue lines
      "\\tikz \\draw [line width=.25em, theblue] (2-|1) -- (2-|last) ;",
      "\\tikz \\draw [line width=.25em, theblue] (last-|1) -- (last-|last) ;"
    ),
    collapse = "\n"
  )

  add_tagged_table(xshift = xshift, yshift = yshift + 15, col_layout = col_layout, body = body, code_after = code_after)
}