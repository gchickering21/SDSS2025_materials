#------------------------------ SETUP PARALLEL CONFIGURATION ------------------------------#
# Set up parallel backend
num_cores <- detectCores()
cl <- makeCluster(num_cores, outfile = "")
registerDoSNOW(cl)

# Extract the names of functions loaded in config.R
loaded_functions <- ls(envir = environment())

# Exclude any variables that might have been loaded
exported_functions <- loaded_functions[sapply(loaded_functions, function(x) is.function(get(x)))]

# Filter out variables already being exported
exported_functions <- exported_functions[!exported_functions %in% c(
  "add_bold_fig_labels", "check_page_version",
  "clean_5essentials_table", "clean_fig4c2",
  "clean_grade_table", "clean_ind_turnaround_table",
  "cleanData", "cleanDataDict", "cleanDataList",
  "cleanDataList_Fig", "cleanDataList_Table", "cleanFolders",
  "cleanup_school_names", "counts_to_percents",
  "determine_version_number", "extract_counts",
  "extract_JSON", "extract_values", "find_update_text",
  "fix_ratings_spelling", "fix_special_characters",
  "fix_special_characters_string", "generate_class_obs_notes",
  "generate_class_obs_qc", "generate_data_package",
  "generate_preliminary_rating_notes", "generate_school_update_text",
  "generate_staff_survey_qc", "makeFolders", "prepData",
  "replace_abbr_with_full", "removeSchoolTempFolder", "removeTexOutputFiles",
  "print_error", "print_warning", "generate_review_sheet",
  "remove_hyphen", "remove_spaces", "space_to_underscore", "fix_quotes",
  "remove_single_quotes", "make_error_msg", "make_warning_msg", "clean_msg",
  "cleanIntermediates", "escape_name", "get_update_text_filename",
  "add_ind", "add_ind1A", "add_ind1B", "add_ind1C", "add_ind1D", "add_ind2A",
  "add_ind2B", "add_ind2D", "add_ind2E", "add_ind3A", "add_ind3B", "add_ind3D",
  "add_ind3E", "add_ind4A", "add_ind4B", "add_schoolintro", "makeReport"
)]
