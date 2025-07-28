# SDSS2025_materials
Used to provide supplementary materials for submission to Journal of Data Science - 2025

## aiPipeline-sdss2025

This folder contains all the necessary code and instructions to understand how the Audio File AI Pipeline operates. A further detailed README is provided within the subfolder and includes:

- A high-level overview of the pipeline architecture
- Step-by-step instructions for running key components locally (where feasible)
- Descriptions of each processing stage (transcription, diarization, tagging, summarization)
- Sample input/output files for illustration
- Notes on dependencies and cloud services used (e.g., WhisperX, OpenAI GPT models, Kubernetes)

Due to infrastructure dependencies, some components are tightly coupled to internal cloud environments (AWS and Azure) and cannot be fully reproduced externally. Where this is the case, mock data and walkthroughs are included to demonstrate the pipeline’s logic and outputs.

## autoreportsPipeline-sdss2025

This folder contains supporting code and documentation for the Report Running Pipeline. It includes:

- Scripts and helper functions used for report generation
- An overview of the cloud orchestration process (using AWS Step Functions, Lambda, EC2, SES, and Airtable)
- Instructions for viewing or simulating the pipeline logic
- Example templates and sample reports (using mock data)

Because this pipeline relies on private APIs, secure credentials, and proprietary datasets, it is not directly runnable outside of our internal environment. However, extensive documentation and sample artifacts are included to support transparency and understanding. We have also included mock data and output to allow users to download a Docker image and generate a sample report themselves to see what the final output contains and looks like

## Notes on Reproducibility

To balance transparency with data security, this repository focuses on explaining the system design, logic, and typical outputs using sanitized data and non-sensitive materials. Users are encouraged to reference the included README files in each subdirectory for further technical detail and implementation guidance.

Please contact the corresponding author with questions or for clarification about particular components of the system.
