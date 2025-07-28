# Function to determine action based on row values
# Function to determine action based on school data
determine_version_number <- function(df, rcdts_key) {
  # Filter the dataframe for the specified school
  school <- df %>%
    filter(rcdts == rcdts_key)

  # Assuming the dataframe has only one row per school. If not, you might need to adjust this part.
  if (nrow(school) == 0) {
    return("School not found")
  }

  # Check conditions
  if (!is.na(school$done) && school$done == "DONE") {
    return("Report is done")
  } else if (!is.na(school$v3) && school$v3 == "READY") {
    return("v3")
  } else if (!is.na(school$v2) && school$v2 == "READY") {
    return("v2")
  } else if (!is.na(school$v1) && school$v1 == "READY") {
    return("v1")
  } else {
    return("Do not run any version")
  }
}
