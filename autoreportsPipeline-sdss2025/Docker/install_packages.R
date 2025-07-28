# install_packages.R

# Define the file with the list of packages
requirements_file <- "requirements.txt"

# Read package names from the file
packages <- readLines(requirements_file)

for (pkg in packages) {
  tryCatch(
    {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        message(paste("Installing package:", pkg))
        install.packages(pkg, repos = "https://cloud.r-project.org", verbose = TRUE)
      } else {
        message(paste("Package already installed:", pkg))
      }
    },
    error = function(e) {
      message(paste("Error installing package:", pkg, "\n", e))
    }
  )
}
