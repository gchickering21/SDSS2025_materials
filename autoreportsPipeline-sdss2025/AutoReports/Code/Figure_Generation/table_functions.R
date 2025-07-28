
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
# AUTHOR: Michael Kruse
# Purpose: Backend R code to easily create (tagged) highly customizable LaTeX tables without having to get lost in LaTeX.
# DATE CREATED:
# 12/19/2023
# UPDATED: 3/8/2024
# NOTES: Uses NiceTabular LaTeX package to build tables. "MyTabular" environment is defined in mystyles.sty
#        to make arraystretch modifications easier on a table-by-table basis.
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------

# Function that takes a list of named parameters. When building a table, each parameter that is not specified in create_rows will instead use the param specified here
set_params <- function(params = NA) {
  # Should only assign to valid table params (to prevent overriding other global variables)
  valid_params <- c(
    "row_sep", "sep_at_end", "hprefix", "hsuffix", "dprefix", "dsuffix", "cell_types", "hscope", "newline", "ignore_mods",
    "row_color", "precision", "hfont_color", "hfont_family", "hfont_size", "dfont_color", "dfont_family", "dfont_size",
    "hbold", "hitalic", "dbold", "ditalic", "arraystretch"
  )
  params <- params[names(params) %in% valid_params]
  assign("table_params", params, envir = .GlobalEnv)
}


# High-level function used to place the table in a node. This is what will be called to actually build the table
add_tagged_table <- function(xshift, yshift, col_layout, head = "", body = "", foot = "", additional_options = "color-inside", anchor = "north west", alt = NA, code_before = "",
                             code_after = "", hide_lines = list(rows = NA, ncol = NA, color = "thewhite"), arraystretch = NA) {
  return(cat(paste0(
    "\\node[anchor=", anchor, ",xshift=", xshift, ",yshift=", yshift, "] at (current page.", anchor, ") {\n",
    tagged_table(col_layout = col_layout, head = head, body = body, foot = foot, additional_options = additional_options, alt = alt, code_before = code_before, code_after = code_after, hide_lines = hide_lines, arraystretch = arraystretch),
    "\n};"
  )))
}
# High level function to create the table. Tables consist of a couple different parts:
# Metadata/table parameters (column layout and any additional parameters for NiceTabular)
# code_before - code to be executed before table creation (to be passed to \CodeBefore)
# THead - table header
# TBody - table body
# TFoot - table foot
# code_after - code to be executed after table creation (to be passed to \CodeAfter)
# Not all parts are needed or present in all tables
tagged_table <- function(col_layout, head = "", body = "", foot = "", additional_options = "color-inside", alt = NA, code_before = "", code_after = "",
                         hide_lines = list(rows = NA, ncol = NA, color = "thewhite"), arraystretch = arraystretch) {
  table_setup <- start_table(col_layout, additional_options, code_before, alt = alt, arraystretch = arraystretch)
  if (head != "") {
    head <- wrap_section(head, tag = "THead")
  }
  if (body != "") {
    body <- wrap_section(body, tag = "TBody")
  }
  if (foot != "") {
    foot <- wrap_section(foot, tag = "TFoot")
  }
  
  
  hide_line_latex <- ""
  if (!all(is.na(hide_lines$rows))) {
    if (is.null(hide_lines$color)) {
      hide_lines$color <- "thewhite"
    }
    if (length(hide_lines$color) == 1) {
      hide_lines$color <- rep(hide_lines$color, length(hide_lines$rows))
    }
    for (i in 1:length(hide_lines$rows)) {
      for (j in 2:(hide_lines$ncol)) {
        hide_line_latex <- paste0(hide_line_latex, "\\tikz \\draw [", hide_lines$color[i], "] (", hide_lines$rows[i], "-|", j, ") -- (", hide_lines$rows[i] + 1, "-|", j, ") ;\n")
      }
    }
  }
  code_after <- paste0(hide_line_latex, code_after)
  
  table_end <- end_table(code_after)
  
  table <- paste0(table_setup, head, body, foot, table_end)
  
  # reset global params
  if (exists("table_params")) {
    rm(table_params, envir = .GlobalEnv)
  }
  
  return(table)
}

# Function to create one or more rows of the same format with optional row separator to avoid having to write the same code repeatedly
create_rows <- function(data, row_sep = "", sep_at_end = TRUE, hprefix = "", hsuffix = "", dprefix = "", dsuffix = "", cell_types = NA, hscope = "row", newline = TRUE, ignore_mods = FALSE,
                        row_color = NA, precision = NA, hfont_color = NA, hfont_family = NA, hfont_size = NA, dfont_color = NA, dfont_family = NA, dfont_size = NA,
                        hbold = FALSE, hitalic = FALSE, dbold = FALSE, ditalic = FALSE) {
  # Check which args are explicitly set
  explicit_args <- gsub("^create_rows\\(|)$", "", deparse(match.call()))
  explicit_args <- unlist(str_extract_all(explicit_args, "\\b\\S+(?=\\s*=)"))
  # Use these explicit values over any global params being set
  if (exists("table_params")) {
    for (i in 1:length(table_params)) {
      if (!names(table_params)[i] %in% explicit_args) {
        assign(names(table_params)[i], table_params[i][[1]])
      }
    }
  }
  
  rows <- ""
  if (is.vector(data)) {
    data <- rbind(data)
  }
  for (i in 1:nrow(data)) {
    if (sep_at_end == FALSE & i == nrow(data)) {
      row_sep <- ""
    }
    # Having a row sep without a new line throws an error
    # (Only look at the newline argument when on the last line)
    if (i == nrow(data) & newline == FALSE) {
      rows <- paste0(rows, create_row(data[i, ],
                                      row_sep = "", hprefix = hprefix, hsuffix = hsuffix, dprefix = dprefix, dsuffix = dsuffix, cell_types = cell_types, hscope = hscope,
                                      newline = newline, ignore_mods = ignore_mods, row_color = row_color, precision = precision, hfont_color = hfont_color,
                                      hfont_family = hfont_family, hfont_size = hfont_size, dfont_color = dfont_color, dfont_family = dfont_family, dfont_size = dfont_size,
                                      hbold = hbold, hitalic = hitalic, dbold = dbold, ditalic = ditalic
      ))
    } else {
      rows <- paste0(rows, create_row(data[i, ],
                                      row_sep = row_sep, hprefix = hprefix, hsuffix = hsuffix, dprefix = dprefix, dsuffix = dsuffix, cell_types = cell_types, hscope = hscope,
                                      newline = TRUE, ignore_mods = ignore_mods, row_color = row_color, precision = precision, hfont_color = hfont_color,
                                      hfont_family = hfont_family, hfont_size = hfont_size, dfont_color = dfont_color, dfont_family = dfont_family, dfont_size = dfont_size,
                                      hbold = hbold, hitalic = hitalic, dbold = dbold, ditalic = ditalic
      ))
    }
  }
  return(rows)
}
# The main function for table creation. Creates a row of a table. See below for details on various parameters:
# If no scope for the header(s) in this row are specified, they are set to TH-row
# row_sep is latex code to insert after the row, typically for drawing lines between rows
# hprefix/hsuffix are things to insert before/after the headers (either text or LaTeX)
# dprefix/dsuffix are things to insert before/after the data (either text or LaTeX)
# cell_types defines which cells are headers and which are data. Should either be "TH" or "TD" to set all to one type, or a vector of cell types.
#  If not set, assumes the first column is a header and the rest are data
# hscope defines the attribute for each header tag in the row. Can be a single value to set all headers, or a vector of values. The vector should match the # of total columns,
#  even if data cells exist in the row. The actual values set for the data cells will be ignored. Can take values "row","col", and "both"
# newline determines if a new line should be created after the row. CAUTION: setting newline=FALSE with a row_sep defined may throw an error
# ignore_mods will skip the prefix and suffix modifications for the row. This can be useful for when the prefix/suffix is set at the table-level
# row_color sets the row color
# precision defines the number of decimal places to display for each data cell. Only works if data cells are stored as numeric. This should ideally be done in Data_Prep,
#  but is included here if needed
# hfont/dfont settings specify font info for header and data cells, respectively
# hbold/hitalic and dbold/ditalic will cause headers/data to be bold/italic. Only works if the font file supports bold/italic faces
create_row <- function(cells, row_sep = "", hprefix = "", hsuffix = "", dprefix = "", dsuffix = "", cell_types = NA, hscope = "row", newline = TRUE, ignore_mods = FALSE,
                       row_color = NA, precision = NA, hfont_color = NA, hfont_family = NA, hfont_size = NA, dfont_color = NA, dfont_family = NA, dfont_size = NA,
                       hbold = FALSE, hitalic = FALSE, dbold = FALSE, ditalic = FALSE) {
  row <- ""
  if (!is.na(row_color)) {
    row <- paste0(row, "\\rowcolor{", row_color, "}")
  }
  # If no cell types are specified, assume the first cell is a header and the rest are data
  if (all(is.na(cell_types))) {
    cell_types <- c("TH", rep("TD", length(cells) - 1))
  } else if (length(cell_types) == 1) { # If only once cell type is specified, apply it to all cells in the row
    cell_types <- rep(cell_types, length(cells))
  }
  if (length(hscope) == 1) { # If only one header scope is specified, apply it to all cells in the row
    # If multiple header types are specified, there must be an entry for ALL rows, even data rows.
    # The entries in data rows will be ignored, but are needed for proper indexing
    hscope <- rep(hscope, length(cells))
  } else if (length(hscope) < length(cells)) { # If not enough scopes are specified, repeat the last scope for the rest of the cells
    hscope <- c(hscope, rep(hscope[length(hscope)], length(cells) - length(hscope)))
  }
  for (i in 1:length(cells)) {
    curr_cell <- cells[i]
    # Only wrap tag and add prefix/suffix if the cell has content
    if (curr_cell != "") {
      if (curr_cell == " ") { # Users can insert a space to leave a blank cell (empty cells get skipped entirely)
        row <- paste0(row, " ")
      } else {
        # If cell is a header, add header prefix/suffix, set header font, and wrap in TH tag
        if (cell_types[i] == "TH") {
          if (!ignore_mods) {
            curr_cell <- paste0(hprefix, curr_cell, hsuffix)
          }
          if (hbold) {
            curr_cell <- paste0("\\textbf {", curr_cell, "}")
          }
          if (hitalic) {
            curr_cell <- paste0("\\textit {", curr_cell, "}")
          }
          # Set the font size if specified
          if (all(!is.na(hfont_size))) {
            # Font sizes are supposed to have 2 values, but users may only input the first value
            if (length(hfont_size == 1)) {
              hfont_size <- c(hfont_size, 1.2 * hfont_size)
            }
            curr_cell <- paste0("\\fontsize{", hfont_size[1], "}{", hfont_size[2], "}\\selectfont{", curr_cell, "}")
          }
          # Set the font family if specified - assumes the font is defined in mystyles.sty, as it is called via \\fontname
          if (!is.na(hfont_family)) {
            curr_cell <- paste0("\\", hfont_family, " ", curr_cell)
          }
          # Set the font color if specified
          if (!is.na(hfont_color)) {
            curr_cell <- paste0("\\textcolor{", hfont_color, "}{", curr_cell, "}")
          }
          row <- paste0(row, wrap_cell(curr_cell, attribute = paste0("TH-", hscope[i])))
        } else { # If cell is data, add data prefix/suffix, set data font, and wrap in TD tag
          # The # of decimals (precision) is probably better handled in Data_Prep, but can be included here if needed
          if (!is.na(precision) & is.numeric(curr_cell)) {
            curr_cell <- sprintf(fmt = "%.", precision, "f", curr_cell)
          }
          if (!ignore_mods) {
            curr_cell <- paste0(dprefix, curr_cell, dsuffix)
          }
          if (dbold) {
            curr_cell <- paste0("\\textbf {", curr_cell, "}")
          }
          if (ditalic) {
            curr_cell <- paste0("\\textit {", curr_cell, "}")
          }
          # Set the font size if specified
          if (all(!is.na(dfont_size))) {
            # Font sizes are supposed to have 2 values, but users may only input the first value
            if (length(dfont_size == 1)) {
              dfont_size <- c(dfont_size, 1.2 * dfont_size)
            }
            curr_cell <- paste0("\\fontsize{", dfont_size[1], "}{", dfont_size[2], "}\\selectfont{", curr_cell, "}")
          }
          # Set the font family if specified
          if (!is.na(dfont_family)) {
            curr_cell <- paste0("\\", dfont_family, " ", curr_cell)
          }
          # Set the font color if specified
          if (!is.na(dfont_color)) {
            curr_cell <- paste0("\\textcolor{", dfont_color, "}{", curr_cell, "}")
          }
          row <- paste0(row, wrap_cell(curr_cell))
        }
      }
    }
    if (i != length(cells)) {
      row <- paste0(row, " & \n")
    }
  }
  row <- wrap_row(row, add_newline = newline)
  if (row_sep != "") {
    row <- paste0(row, row_sep, "\n")
  }
  
  
  return(row)
}

# Creates the LaTeX to initialize the table
start_table <- function(col_layout, additional_options = "color-inside", code_before = "", alt = NA, arraystretch = NA) {
  if (code_before != "") {
    code_before <- paste0(" \\CodeBefore\n ", code_before, "\n \\Body\n ")
  }
  # Check global settings for arraystretch if not specified
  if (is.na(arraystretch)) {
    if (exists("table_params")) {
      arraystretch <- table_params$arraystretch
      if (is.null(arraystretch)) {
        arraystretch <- ""
      }
    } else {
      arraystretch <- ""
    }
  }
  
  if (!is.na(alt) & alt != "") {
    return(paste0("\\begin{MyNiceTabular}[", arraystretch, "][", additional_options, "]{", col_layout, "}\n", code_before, "\\tagstructbegin{tag=Table,alt={", alt, "}}\\tagmcbegin{tag=Table,alt={", alt, "}}\n"))
  } else {
    return(paste0("\\begin{MyNiceTabular}[", arraystretch, "][", additional_options, "]{", col_layout, "}\n", code_before, "\\tagstructbegin{tag=Table}\\tagmcbegin{tag=Table}\n"))
  }
}
# Creates the LaTeX to end the table
end_table <- function(code_after = "") {
  if (code_after != "") {
    code_after <- paste0(" \\CodeAfter\n", code_after, "\n ")
  }
  return(paste0("\\tagstructend\\tagmcend\n", code_after, "\\end{MyNiceTabular}"))
}

# Creates THead, TBody, TFoot tags
wrap_section <- function(section, tag) {
  return(paste0("\\tagstructbegin{tag=", tag, "}\n", section, "\\tagstructend\n"))
}
# Creates TR tags
wrap_row <- function(row, add_newline = FALSE) {
  if (add_newline == TRUE) {
    return(paste0(wrap_section(row, tag = "TR"), "\\\\ \n"))
  } else {
    return(wrap_section(row, tag = "TR"))
  }
}
# Creates TH and TD tags
wrap_cell <- function(cell_content, tag = "TD", attribute = NA) {
  if (is.na(attribute)) {
    wrapped_cell <- paste0("\\tagstructbegin{tag=", tag, "}\\tagmcbegin{tag=", tag, "}\n", cell_content, "\\tagmcend\\tagstructend\n")
  } else {
    # Only TH tags have attributes (header scope)
    tag <- "TH"
    wrapped_cell <- paste0("\\tagstructbegin{tag=", tag, ",attribute=", attribute, "}\\tagmcbegin{tag=", tag, "}\n", cell_content, "\\tagmcend\\tagstructend\n")
  }
  return(wrapped_cell)
}
