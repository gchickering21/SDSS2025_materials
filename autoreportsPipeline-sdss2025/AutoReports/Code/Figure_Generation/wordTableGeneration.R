# Function to convert cropped PDFs to PNGs. Utilizies ImageMagick.
# Can change density (DPI) for higher resolution if needed,
# however this will increase time it takes to run
# Function to convert cropped PDFs to PNGs. Utilizies ImageMagick.
# Can change density (DPI) for higher resolution if needed,
# however this will increase time it takes to run
convert_pdf_to_png <- function(pdf_dir, png_dir, density) {
  # Making a directory however this would be changed to a temp dir when implemented
  if (!dir.exists(png_dir)) {
    dir.create(png_dir)
  }

  # Change input_folder(pdf_dir) to temp location for created pdfs
  pdf_files <- list.files(pdf_dir, pattern = "\\.pdf$", full.names = TRUE)


  for (pdf_file in pdf_files) {
    # Maintain the same names as the pdfs
    pdf_name <- tools::file_path_sans_ext(basename(pdf_file))

    # Temp output locaton
    png_file <- file.path(png_dir, paste0(pdf_name, ".png"))

    image <- magick::image_read_pdf(pdf_file, density = density)
    trimmed_image <- magick::image_trim(image)
    magick::image_write(trimmed_image, path = png_file, format = "png")
  }
}

copy_rmd_files <- function(output_path) {
  input_path = "Templates/tables"
  
  # Ensure the output directory exists
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }
  
  # Get a list of all .RMD files in the input directory
  rmd_files <- list.files(input_path, pattern = "\\.RMD$", ignore.case = TRUE, full.names = TRUE)
  
  # Check if there are .RMD files to copy
  if (length(rmd_files) == 0) {
    message("No .RMD files found in the specified directory.")
    return(invisible(NULL))
  }
  
  # Copy each .RMD file to the output directory
  for (file in rmd_files) {
    file.copy(file, output_path, overwrite = TRUE)
  }
  
  message(length(rmd_files), " .RMD file(s) copied to ", output_path)
}


copy_latex_folder <- function(output_path) {
  input_path = "LaTeX"
  output_path <- file.path(output_path, "Latex")
  
  # Ensure the output directory exists
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
  }
  
  # Get a list of all files in the input directory
  all_files <- list.files(input_path, full.names = TRUE)
  
  # Check if there are files to copy
  if (length(all_files) == 0) {
    message("No files found in the Latex directory.")
    return(invisible(NULL))
  }
  
  # Copy each file to the output directory
  for (file in all_files) {
    file.copy(file, output_path, overwrite = TRUE)
  }
  
  message(length(all_files), " LaTeX file(s) copied to ", output_path)
}


# Example usage
# copy_rmd_files("path/to/new/folder")


generate_table_images <- function(report, reportData, reportText, staff_survey_respondents, 
                                  name_school_district, district, school, report_parts_school,ind_student_perspec, 
                                  ind3c_result, ind4c_result, ind4d_result, page21_result, page22_result, page42_result,
                                  static_text, output_path) {
  # INTRO
  
  # Print the current working directory for reference
  print(getwd())
  # Construct the full path to the output directory
  output_dir <- file.path(getwd(), output_path, "Temp")
  print("this is the output dir")
  print(output_dir)
  # Ensure the output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  ## Copy all RMD files into template dir
  copy_rmd_files(output_dir)
  copy_latex_folder(output_dir)
  
  template_path <- paste0(output_dir ,"/Latex/test_template.tex")
  print("ding ding ding got to here")
  
  if (!file.exists(template_path)) {
    stop(paste("Error: Template file does not exist at path:", template_path))
  } else {
    print("Template file exists. Proceeding with rendering.")
  }
  
  # Render the RMarkdown file with the correct LaTeX template
  rmarkdown::render(
    input = file.path(output_dir, "introRatingTable.Rmd"),
    output_file = file.path(output_dir, "introRatingTable.pdf"),
    output_format = rmarkdown::pdf_document(
      latex_engine = "lualatex",
      template = normalizePath(template_path, mustWork = TRUE)
    )
  )
  
  print("after intro rating table")

  #1A
  if(is.character(static_text[['ind1a_rating']])){gen_indHeader(output_dir, 'ind1A', static_text[['ind1a_rating']], template_path)}
  gen_5e(output_dir, "tbl1a", reportData[["tbl1a"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig1a"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))

  # #1B
  if(is.character(static_text[['ind1b_rating']])){gen_indHeader(output_dir, 'ind1B', static_text[['ind1b_rating']], template_path)}
  gen_5e(output_dir, "tbl1b", reportData[["tbl1b"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig1b"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #1C
  if(is.character(static_text[['ind1c_rating']])){gen_indHeader(output_dir, 'ind1C', static_text[['ind1c_rating']], template_path)}
  gen_5e(output_dir, "tbl1c", reportData[["tbl1c"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig1c.1"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  add_survey_response_graphic(data =  reportData[["fig1c.2"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #1D
  if(is.character(static_text[['ind1d_rating']])){gen_indHeader(output_dir, 'ind1D', static_text[['ind1d_rating']], template_path)}
  gen_5e(output_dir, "tbl1d", reportData[["tbl1d"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig1d.1"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  add_survey_response_graphic(data =  reportData[["fig1d.2"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  # add_survey_response_graphic(data =  reportData[["fig1d.3"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #2A
  if(is.character(static_text[['ind2a_rating']])){gen_indHeader(output_dir, 'ind2A', static_text[['ind2a_rating']], template_path)}
  add_survey_response_graphic(data =  reportData[["fig2a"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))

  # # #2B
  if(is.character(static_text[['ind2b_rating']])){gen_indHeader(output_dir, 'ind2B', static_text[['ind2b_rating']], template_path)}
  gen_5e(output_dir, "tbl2b", reportData[["tbl2b"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig2b.1"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  add_survey_response_graphic(data =  reportData[["fig2b.2"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))

  # #2C
  if(is.character(static_text[['ind2c_rating']])){
    gen_indHeader(output_dir, 'ind2C', static_text[['ind2c_rating']], template_path)
  }

  gen_classObs(output_dir, 'tbl2c.1', reportData, "CUCD", template_path)
  if(report_parts_school$content_understanding == TRUE){
    gen_classObs(output_dir, 'tbl2c.2', reportData, 'AI', template_path)
  }
  gen_classObs(output_dir, 'tbl2c.3', reportData, 'LMID', template_path)
  add_survey_response_graphic(data =  reportData[["fig2c"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))

  #
  # #2D
  if(is.character(static_text[['ind2d_rating']])){gen_indHeader(output_dir, 'ind2D', static_text[['ind2d_rating']], template_path)}
  add_survey_response_graphic(data =  reportData[["fig2d"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))

  #
  # #2E
  if(is.character(static_text[['ind2e_rating']])){gen_indHeader(output_dir, 'ind2E', static_text[['ind2e_rating']], template_path)}
  add_survey_response_graphic(data =  reportData[["fig2e.1"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  add_survey_response_graphic(data =  reportData[["fig2e.2"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #3A
  if(is.character(static_text[['ind3a_rating']])){gen_indHeader(output_dir, 'ind3A', static_text[['ind3a_rating']], template_path)}
  gen_5e(output_dir, "tbl3a", reportData[["tbl3a"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig3a"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #3B
  if(is.character(static_text[['ind3b_rating']])){gen_indHeader(output_dir, 'ind3B', static_text[['ind3b_rating']], template_path)}
  gen_classObs(output_dir, 'tbl3b.1', reportData, 'PC', template_path)
  gen_classObs(output_dir, 'tbl3b.2', reportData, 'TS', template_path)
  gen_classObs(output_dir, 'tbl3b.3', reportData, 'BM', template_path)
  gen_classObs(output_dir, 'tbl3b.4', reportData, 'PD', template_path)
  gen_classObs(output_dir, 'tbl3b.5', reportData, 'NC', template_path)
  add_survey_response_graphic(data =  reportData[["fig3b"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #3C
  if (report_parts_school$student_voice_ind3c) {
    if(is.character(static_text[['ind3c_rating']])){gen_indHeader(output_dir, 'ind3C', static_text[['ind3c_rating']], template_path)}
    add_survey_response_graphic(data =  reportData[["fig3c"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
    gen_classObs(output_dir, 'tbl3c', reportData, 'RSP', template_path)
  }
  
  #
  # #3D
  if(is.character(static_text[['ind3d_rating']])){gen_indHeader(output_dir, 'ind3D', static_text[['ind3d_rating']], template_path)}
  gen_5e(output_dir, "tbl3d", reportData[["tbl3d"]], name_school_district, template_path)
  add_survey_response_graphic(data =  reportData[["fig3d.1"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  add_survey_response_graphic(data =  reportData[["fig3d.2"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #3E
  if(is.character(static_text[['ind3e_rating']])){gen_indHeader(output_dir, 'ind3E', static_text[['ind3e_rating']], template_path)}
  add_survey_response_graphic(data =  reportData[["fig3e"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # # #4A
  if(is.character(static_text[['ind4a_rating']])){gen_indHeader(output_dir, 'ind4A', static_text[['ind4a_rating']], template_path)}
  add_survey_response_graphic(data =  reportData[["fig4a"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #4B
  if(is.character(static_text[['ind4b_rating']])){gen_indHeader(output_dir, 'ind4B', static_text[['ind4b_rating']], template_path)}
  gen_classObs(output_dir, 'tbl4b.1', reportData, 'ILF', template_path)
  
  if(report_parts_school$quality_feedback == TRUE){
    gen_classObs(output_dir, 'tbl4b.2', reportData, 'QF', template_path)
  }
  
  if(report_parts_school$student_engagement == TRUE){
    gen_classObs(output_dir, 'tbl4b.3', reportData, 'SE', template_path)
  }
  
  add_survey_response_graphic(data =  reportData[["fig4b"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  #
  # #4C
  if (report_parts_school$enrichment_ind4c) {
    if(is.character(static_text[['ind4c_rating']])){gen_indHeader(output_dir, 'ind4C', static_text[['ind4c_rating']], template_path)}
    add_survey_response_graphic(data =  reportData[["fig4c.1"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
    add_survey_response_graphic(data =  reportData[["fig4c.2"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  }
  #
  # #4D
  if (report_parts_school$college_ind4d) {
    if(is.character(static_text[['ind4d_rating']])){gen_indHeader(output_dir, 'ind4D', static_text[['ind4d_rating']], template_path)}
    add_survey_response_graphic(data =  reportData[["fig4d"]], scale = 15, report_name = name_school_district, output_path = paste0(output_dir, "/Tables"))
  }

  convert_pdf_to_png(output_dir, paste0(output_dir, "/Tables"), density = 300)
}

gen_indHeader <- function(output_dir, ind, rating,template_path){
  print(getwd())
  rmarkdown::render(
    input = file.path(output_dir, "/indRatingHeader.Rmd"),
    params = list(
      rating = rating,
    ),
    output_file = paste0(output_dir, "/", ind, "_header.pdf"),
    output_format = rmarkdown::pdf_document(
      latex_engine = "lualatex",
      template = normalizePath(template_path, mustWork = TRUE)
    )
  )
}



gen_5e <- function(output_path, table, reportData_table, name_school_district,template_path){
  # print("this is the output path")
  # print(output_path)
  add_table_graphic(data=data.frame(Figure_num=reportData_table$Figure_num[1],value=mean(reportData_table$Score,na.rm=T)), xshift=472, yshift=-100, height=460, width=260, text_scalar=2, scale=8, report_name = name_school_district, output_path = paste0(output_path, "/Tables"))
  
  tbl_name <- as.character(table)
  rmarkdown::render(
    input = file.path(output_path, '5eTable.Rmd'),
    params = list(
      reportData_table = reportData_table,
      tbl = tbl_name,
      name_school_district = name_school_district,
      output_path = output_path
    ),
    output_file = paste0(output_path, "/5e_", tbl_name, ".pdf"),
    output_format = rmarkdown::pdf_document(
      latex_engine = "lualatex",
      template = normalizePath(template_path, mustWork = TRUE)
    )
  )
}

gen_classObs <- function(output_path, table, reportData, name,template_path){
  co_data <- reportData[[table]]
  rmarkdown::render(
    input = file.path(output_path, 'classObsTable.Rmd'),
    params = list(
      co_data = co_data
    ),
    output_file = paste0(output_path, "/CO_", name, ".pdf"),
    output_format = rmarkdown::pdf_document(
      latex_engine = "lualatex",
      template = normalizePath(template_path, mustWork = TRUE)
    )
  )

}
# input_folder <- "Output/Testing_District/Testing_School/"
# output_folder <- "Output/Testing_District/PNGs"
#
# convert_pdf_to_png(input_folder, output_folder, density = 300) #Set DPI
