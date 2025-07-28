get_standard_text <- function(schools_like_us_list, section, i = 1, type = "Full.Text", rcdts_key) {
  #' Get relevant schools like us text for a specific school
  #'
  #' @param schools_like_us_list
  #' @param section
  #' @param i
  #' @param type
  #' @param school_district_name
  #' @example get_standard_text(schools_like_us_list,'Targeted_Instruction_and_Support',i=1,type="Full.Text", "Lincoln Elem School- Anna CCSD 37")

  df <- schools_like_us_list[section][[i]]
  text <- df[df$RCDTS == rcdts_key, type]
  # format newlines
  text <- gsub("\\\\", " \\hfill\\break ", text, fixed = TRUE)

  # construct list latex
  text <- gsub("<list>", "\\vspace{2mm}\\begin{itemize}", text, fixed = TRUE)
  text <- gsub("<bullet>", "\\vspace{1mm}\\item ", text, fixed = TRUE)
  text <- gsub("</list>", "\\end{itemize}", text, fixed = TRUE)

  # construct footnote indicator latex for any footnote number using capture groups
  text <- gsub("<footnote (\\d)_num>", "$^\\1$", text)
  text <- gsub("<footnote ,>", "$^,$", text)



  # construct footnote text latex
  text <- gsub(
    "<footnote (\\d)_text>(.*?)</footnote_text>",
    "\\\\newline\\\\vfill$^\\1${\\\\footnotesize \\2}",
    text
  )

  # Italicize p-value
  text <- gsub("p-value", "\\\\italicfont p-\\\\regular value", text)

  # deal with percents
  text <- gsub("%", "\\%", text, fixed = TRUE)

  # idk there's a weird bug with the first Schools after a paragraph
  text <- gsub("(\\. \\\\hfill\\\\break) Schools", "\\1\\\\vfill Schools", text)

  text <- gsub("(\\. \\\\hfill\\\\break) Schools", "\\1\\\\vfill Schools", text)
  # print(text)
  text <- gsub("\\\\begin\\{itemize\\}\\\\end\\{itemize\\}", "", text)

  text <- gsub("/par", "\\\\\\vspace{2mm}", text)

  return(text)
}
