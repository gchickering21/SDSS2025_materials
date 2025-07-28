# Autoreports File Structure

## File structure without descriptions

* **Base folder**
    * *container.bat*
    * *container.sh*
    * *.gitignore*
    * *README.md*
    * ...
    * **AutoReports**
        * *config.R*
        * *report_shell.R*
        * *report.Rmd*
        * ...
        * **Code**
            * **Data_Prep**
                * *data_processing.R*
                * ...
            * **Figure_Generation**
                * *insert_plots.R*
                * *plotting_functions.R*
                * *insert_tables.R*
                * *table_functions.R*
                * ...
            * **Helpers**
                * *file_management.R*
                * *wrap508.R*
                * ...
        * **Data**
            * **Raw_Data_Files**
                * *autoreports_data.xlsx*
                * ...
            * **Text_Files**
                * *text.xlsx*
                * ...
            * **(Temp)**
                * *fig1.png*
                * ...
        * **Images and Assets**
                * *logo.png*
                * ...
        * **LaTeX**
            * *mystyles.sty*
            * ...
        * **Output**
            * **_sample output**
                * *mockup.pdf*
                * ...
            * *report.pdf*
            * ...
    * **Docker**
        * *autoreports_project.tar*
        * *Dockerfile*
        * *Dockerfile_base*
        * *install_latex_reqs.py*
        * *install_packages.R*
        * *latex_requirements.txt*
        * *README_docker.md*
        * *requirements.txt*
        * ...
    * **Documentation**
        * *file_structure.md*
        * *README_Docker.md*
        * *README_Reports.md*
        * ...

## File structure with descriptions

* **Base folder**
    * *container.bat* and *container.sh* - starts the docker container (.bat for windows, .sh for mac)
    * *run_all_scripts.py* - main orchestration script to start up and generate reports
    * *.gitignore* - excludes files from being pushed to github
    * *Readme*
    * **AutoReports** (used to be called **volume**) - contains all report-running scripts and subfolders
        * *config.R* - sets up the run of the reports (specify which reports to run, loads data files, loads the .R scripts in the **Code** folder, etc.)
        * *report_shell.R* - orchestrates the running of the reports
        * *report.Rmd* - the code which creates the reports
        * **Code** - contains all .R scripts and backend code for reports
            * **Data_Prep** - contains all data-prep related code (cleaning and transforming)
                * *data_processing.R* – cleans and preps data for use
            * **Figure_Generation** – contains all figure and table-related code (creation and placement)
                * *insert_plots.R* – generates and places figures
                * *plotting_functions.R* – backend ggplot code for figures
                * *insert_tables.R* – generates and places tables
                * *table_functions.R* – backend code to help create tables
            * **Helpers** – contains all other random helper functions
                * *file_management.R* – creates output folders, deletes temp files
                * *wrap508.R* – all-purpose tagging code
        * **Data** – contains all data and assets to be used
            * **Raw_Data_Files**
                * *Unprocessed data files* – may not get used if data comes from a database (can also store .Rdata files here to not have to connect to the database when data is not changed)
            * **Text_Files**
                * Dynamic Text_Files to be used in the reports
            * **(Temp)**
                * Will not be seen by user, but temporary .png files for the figures will be stored here during each run, then the temp folder is deleted after
        * **Images and Assets**
                * *Files provided by project team* – logos, images, etc
        * **LaTeX** – contains all latex-related code and helpers
            * *.sty files and other latex related things*
        * **Output** – contains all output (output files are not pushed to github)
            * **_sample output** - contains mockups (gets pushed to github)
                * Place any provided mockups in here
                * The underscore in naming ensures the folder appears above the reports and is not mixed in
                * Can have this subfolder pushed to github, while the rest of the output remains local
            * *Output files and relevant subfolders*
    * **Docker** – contains all docker code
        * *Docker stuff*
    * **Documentation** - contains documentation on various aspects of AutoReports
        * *various readme's*
