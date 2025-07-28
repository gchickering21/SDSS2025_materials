import glob
import os
from datetime import datetime

import requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv

from scripts.logging_config import root_logger


def print_red(text):
    print(f"\033[1;31m{text}\033[0m")


def print_yellow(text):
    print(f"\033[1;33m{text}\033[0m")


def print_green(text):
    print(f"\033[1;32m{text}\033[0m")


class SharepointAuthentication:
    def __init__(self, config: dict, env_file=".env"):
        load_dotenv(dotenv_path=env_file)
        # Load environment variables from .env file
        self.tenant_id = config.get("sharepoint_tenant_id")
        self.client_id = config.get("sharepoint_client_id")
        self.vault_url = config.get("sharepoint_vault_url")
        self.drive_id = config.get("sharepoint_drive_id")
        self.site_id = config.get("sharepoint_site_id")
        self.secret_name = os.getenv("SHAREPOINT_SECRET_NAME")
        self.sharepoint_root_folder = "Final_Report_Documents"
        self.scopes = ["https://graph.microsoft.com/.default"]

    def initialize_sharepoint(self):
        """Method to authenticate and get access token."""
        self.sharepoint_authenticate()
        self.get_access_token()

    def sharepoint_authenticate(self):
        """Authenticate with Azure Key Vault and get the secret."""
        credential = DefaultAzureCredential(exclude_shared_token_cache_credential=True)
        secret_client = SecretClient(vault_url=self.vault_url, credential=credential)
        secret = secret_client.get_secret(self.secret_name)
        self.client_secret = secret.value
        return secret.value

    def get_access_token(self):
        """Get the access token using client credentials."""
        auth_url = (
            f"https://login.microsoftonline.com/{self.tenant_id}/oauth2/v2.0/token"
        )
        data = {
            "grant_type": "client_credentials",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "scope": "https://graph.microsoft.com/.default",
        }
        # response = requests.post(auth_url, data=data, verify=self.ssl_certificate_path)
        response = requests.post(auth_url, data=data)

        if "access_token" in response.json():
            self.access_token = response.json()["access_token"]
        else:
            print_red(f"\nError retrieving access token: {response.json()}")

    def create_sharepoint_folder(self, folder_path):
        """Create a folder in SharePoint."""
        url = f"https://graph.microsoft.com/v1.0/sites/{self.site_id}/drives/{self.drive_id}/root:/{folder_path}"
        headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }
        data = {
            "name": folder_path.split("/")[-1],
            "folder": {},
            "@microsoft.graph.conflictBehavior": "replace",
        }
        response = requests.patch(url, headers=headers, json=data)
        if response.status_code not in [200, 201]:
            print_red(f"\nFailed to create folder {folder_path}: {response.json()}")

    def file_exists_in_sharepoint(self, sharepoint_file_path):
        """Check if a file exists in SharePoint."""
        url = f"https://graph.microsoft.com/v1.0/sites/{self.site_id}/drives/{self.drive_id}/root:/{sharepoint_file_path}"
        headers = {"Authorization": f"Bearer {self.access_token}"}
        # response = requests.get(url, headers=headers, verify=self.ssl_certificate_path)
        response = requests.get(url, headers=headers)
        return response.status_code == 200

    def upload_file_to_sharepoint(self, local_file_path, sharepoint_file_path):
        """Upload a file to SharePoint."""
        upload_url = f"https://graph.microsoft.com/v1.0/sites/{self.site_id}/drives/{self.drive_id}/items/root:/{sharepoint_file_path}:/content"
        headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/octet-stream",
            "Content-Length": str(os.path.getsize(local_file_path)),
        }
        with open(local_file_path, "rb") as file:
            response = requests.put(upload_url, headers=headers, data=file)
            if response.status_code not in [200, 201]:
                print_red(
                    f"\nFailed to upload {local_file_path} to {sharepoint_file_path}: {response.json()}"
                )

    def upload_final_files_to_sharepoint(self, file_status=None):
        if file_status is None:
            root_logger.error("No file status provided.")
            return

        # Define a dictionary for the folder mapping
        folder_mapping = {
            "transcribed": "word_transcripts",
            "diarized": "word_diarized_transcripts",
            "tagged": "tagged_transcripts",
            "ai_findings_produced": "ai_findings",
        }
        # Loop through each file in the file_status
        for file_name, stages in file_status.items():
            root_logger.info(f"Processing file: {file_name}")

            # Extract the RCDTS value
            rcdts_value = stages.get("rcdts")
            # Find SharePoint folder by RCDTS value
            sharepoint_folder_path = self.find_sharepoint_folder_by_id(rcdts_value)

            file_type = stages.get("audio_file_upload_type", "")

            if not sharepoint_folder_path:
                # Extract school_name and district_name
                school_name = stages.get("school_name", "")
                district_name = stages.get("district_name", "")
                # Construct the folder name in the format: RCDTS_school-name_district-name
                folder_name = f"{rcdts_value}_{school_name}_{district_name}"

                # Log the folder creation
                root_logger.info(
                    f"No folder found for RCDTS {rcdts_value}. Creating folder: {folder_name}..."
                )

                # Construct the full SharePoint folder path
                sharepoint_folder_path = os.path.join(
                    self.sharepoint_root_folder, folder_name
                ).replace("\\", "/")

                # Create the folder in SharePoint
                self.create_sharepoint_folder(sharepoint_folder_path)
                root_logger.info(f"Created folder: {sharepoint_folder_path}")

            for key, subfolder in folder_mapping.items():
                if stages.get(key):
                    root_logger.info(f"Uploading file for {key} to SharePoint...")

                    # Define the local folder path for the subfolder
                    local_folder_path = subfolder

                    # Construct the expected file pattern with a wildcard for any prefix
                    file_pattern = os.path.join(
                        local_folder_path, f"*{file_name}.*"
                    )  # Match any prefix and file extension

                    # Find the matching file
                    matching_files = glob.glob(file_pattern)

                    if not matching_files:
                        root_logger.warning(
                            f"No matching file found for {key} in {local_folder_path} with pattern {file_pattern}. Skipping."
                        )
                        continue

                    # Use the first matching file (assuming one match is correct)
                    local_file_path = matching_files[0]
                    current_date = datetime.now().strftime("%Y-%m-%d")

                    # Define SharePoint file path directly under the sharepoint_folder_path
                    sharepoint_file_path = os.path.join(
                        sharepoint_folder_path,
                        file_type,
                        current_date,
                        os.path.basename(local_file_path),
                    ).replace("\\", "/")

                    # Check if the file already exists in SharePoint
                    if self.file_exists_in_sharepoint(sharepoint_file_path):
                        root_logger.info(
                            f"File {sharepoint_file_path} already exists. Replacing with new version."
                        )

                    # Upload the file to SharePoint
                    self.upload_file_to_sharepoint(
                        local_file_path, sharepoint_file_path
                    )

                    # Log success
                    root_logger.info(
                        f"Uploaded {file_name} for {key} to {sharepoint_file_path}."
                    )
            file_status[file_name]["sent_to_sharepoint"] = True
            root_logger.info(f"Uploaded all appropriate files for {file_name}.")

        root_logger.info("All files processed and uploaded to SharePoint.")
        return file_status

    def find_sharepoint_folder_by_id(self, school_id):
        """Find a SharePoint folder by school ID."""
        url = f"https://graph.microsoft.com/v1.0/sites/{self.site_id}/drives/{self.drive_id}/root/children"
        headers = {"Authorization": f"Bearer {self.access_token}"}
        # response = requests.get(url, headers=headers, verify=self.ssl_certificate_path)
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            items = response.json().get("value", [])
            for item in items:
                if item["folder"] and school_id in item["name"]:
                    return item["parentReference"]["path"] + "/" + item["name"]
        return None
