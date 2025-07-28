import os

from .install_missing_packages import install_missing_packages

try:
    from azure.identity import DefaultAzureCredential
except ImportError:
    install_missing_packages("azure-identity")
    from azure.identity import DefaultAzureCredential
try:
    from azure.identity.aio import ClientSecretCredential
except ImportError:
    install_missing_packages("azure-identity")
    from azure.identity.aio import ClientSecretCredential
try:
    from azure.keyvault.secrets import SecretClient
except ImportError:
    install_missing_packages("azure-keyvault-secrets")
    from azure.keyvault.secrets import SecretClient
try:
    from msgraph import GraphServiceClient
except ImportError:
    install_missing_packages(["msgraph-core", "msgraph-sdk"])
    from msgraph import GraphServiceClient
try:
    from dotenv import load_dotenv
except ImportError:
    install_missing_packages("dotenv")
    from dotenv import load_dotenv
try:
    import requests
except ImportError:
    install_missing_packages("requests")
    import requests
try:
    import boto3
except ImportError:
    install_missing_packages("boto3")
    import boto3
try:
    import json
except ImportError:
    install_missing_packages("json")
    import json
try:
    import re
except ImportError:
    install_missing_packages("re")
    import re
try:
    import shutil
except ImportError:
    install_missing_packages("shutil")
    import shutil
try:
    from datetime import datetime
except ImportError:
    install_missing_packages("datetime")
    from datetime import datetime

os.system(
    ""
)  # For some reason, the ANSI coloring only works on Windows if this is called at the top of the script


def print_red(text):
    print(f"\033[1;31m{text}\033[0m")


def print_yellow(text):
    print(f"\033[1;33m{text}\033[0m")


def print_green(text):
    print(f"\033[1;32m{text}\033[0m")


class SharepointAuthentication:
    def __init__(self, env_file="AutoReports/.env"):
        # Load environment variables from .env file
        load_dotenv(dotenv_path=env_file)
        self.tenant_id = os.getenv("tenant_id")
        self.client_id = os.getenv("client_id")
        self.vault_url = os.getenv("vault_url")
        self.drive_id = os.getenv("drive_id")
        self.site_id = os.getenv("site_id")
        self.ssl_certificate_path = os.getenv("ssl_certificate_path")
        self.local_root = "AutoReports/Output"
        self.sharepoint_root_folder = "Final_Report_Documents"
        self.scopes = ["https://graph.microsoft.com/.default"]
        self.access_token = None
        self.client_secret = None
        self.secret_name = os.getenv("secret_name")
        self.ec2_secret_name = os.getenv("ec2_secret_name")

    def get_ec2_secret(self):
        secret_name = self.ec2_secret_name
        region_name = "us-east-1"

        # Create a Secrets Manager client
        client = boto3.client("secretsmanager", region_name=region_name)

        try:
            # Retrieve the secret value
            response = client.get_secret_value(SecretId=secret_name)

            # Check if the secret is a string or binary
            if "SecretString" in response:
                secret = response["SecretString"]
            else:
                # If the secret is in binary, decode it
                secret = response["SecretBinary"].decode("utf-8")

            # Parse the secret (assuming it's in JSON format)
            secret_dict = json.loads(secret)
            return secret_dict.get("graphapikey")

        except Exception as e:
            print_red(f"\nError retrieving secret: {e}")
            return None

    def pull_secret_ec2_instance(self):
        secret = self.get_ec2_secret()
        print(secret)
        if secret:
            self.client_secret = secret  # Assign the secret directly
            return secret
        else:
            print_red("No secret found.")
            return None

    def initialize_sharepoint_ec2(self):
        """Method to authenticate and get access token."""
        self.pull_secret_ec2_instance()
        self.get_access_token()

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
        response = requests.post(auth_url, data=data, verify=self.ssl_certificate_path)

        if "access_token" in response.json():
            self.access_token = response.json()["access_token"]
        else:
            print_red(f"\nError retrieving access token: {response.json()}")

    def clear_output_folder(self, folder_path):
        """Recursively remove all files and subfolders from the specified folder."""
        if not os.path.exists(folder_path):
            print_green(f"The folder {folder_path} does not exist. Skipping cleanup...")
            return

        removed = True
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    self.clear_output_folder(file_path)
                    os.rmdir(file_path)
            except Exception as e:
                removed = False
                print_red(f"Failed to delete {file_path}. Reason: {e}")

        if removed:
            print_green(f"The folder {folder_path} has been cleared.")

    def clear_text_files_folder(self, folder_path, exceptions):
        """Remove all files from the specified folder except the ones listed in exceptions."""
        if not os.path.exists(folder_path):
            print_green(f"The folder {folder_path} does not exist. Skipping cleanup...")
            return

        removed = True
        for filename in os.listdir(folder_path):
            if filename not in exceptions:
                file_path = os.path.join(folder_path, filename)

                try:
                    if os.path.isfile(file_path) or os.path.islink(file_path):
                        os.unlink(file_path)
                        print_green(f"File {file_path} has been removed.")
                except FileNotFoundError:
                    removed = False
                    print_green(f"File {file_path} does not exist. Skipping cleanup...")
                except Exception as e:
                    removed = False
                    print_red(f"Failed to delete {file_path}. Reason: {e}")

        if removed:
            print_green("The UpdateText_Files have been removed.")

    def remove_specific_files(self, folder_path, files_to_remove):
        """Remove specified files from the given folder."""
        if not os.path.exists(folder_path):
            print_green(f"The folder {folder_path} does not exist. Skipping cleanup...")
            return

        removed = True
        for filename in files_to_remove:
            file_path = os.path.join(folder_path, filename)
            # print(file_path)
            if os.path.exists(file_path):
                try:
                    os.unlink(file_path)
                except Exception as e:
                    removed = False
                    print_red(f"Failed to delete {file_path}. Reason: {e}")
            else:
                removed = False
                print_green(f"File {file_path} does not exist. Skipping cleanup...")

        if removed:
            print_green("SchoolParts and Data Tracking sheets have been removed.")

    async def download_file(self, client, drive_id, file_id, folder_name):
        """Download a file from SharePoint to the local folder."""
        downloaded = True
        try:
            item = (
                await client.drives.by_drive_id(drive_id)
                .items.by_drive_item_id(file_id)
                .get()
            )
            file_name = item.name
            content = (
                await client.drives.by_drive_id(drive_id)
                .items.by_drive_item_id(file_id)
                .content.get()
            )

            if not os.path.exists(folder_name):
                os.makedirs(folder_name)

            file_path = os.path.join(folder_name, file_name)
            with open(file_path, "wb") as f:
                f.write(content)
        except Exception as e:
            downloaded = False
            print_red(f"\nAn error occurred while downloading file {file_id}: {e}")

        if downloaded:
            print_green(f"{file_name} downloaded successfully.")

    async def authenticate_and_clear(self):
        """Authenticate and download files from SharePoint."""
        try:
            # print_yellow("in authenticate_and_download")
            credential = ClientSecretCredential(
                tenant_id=self.tenant_id,
                client_id=self.client_id,
                client_secret=self.client_secret,
            )
            client = GraphServiceClient(credentials=credential, scopes=self.scopes)
            print_green(f"Successfully authenticated with Microsoft Graph: {client}")
            output_folder_path = "AutoReports/Output/"
            self.clear_output_folder(output_folder_path)

        except Exception as e:
            print_red(f"\nAn error occurred: {e}")

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
        response = requests.patch(
            url, headers=headers, json=data, verify=self.ssl_certificate_path
        )
        if response.status_code not in [200, 201]:
            print_red(f"\nFailed to create folder {folder_path}: {response.json()}")

    def file_exists_in_sharepoint(self, sharepoint_file_path):
        """Check if a file exists in SharePoint."""
        url = f"https://graph.microsoft.com/v1.0/sites/{self.site_id}/drives/{self.drive_id}/root:/{sharepoint_file_path}"
        headers = {"Authorization": f"Bearer {self.access_token}"}
        response = requests.get(url, headers=headers, verify=self.ssl_certificate_path)
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
            response = requests.put(
                upload_url, headers=headers, data=file, verify=self.ssl_certificate_path
            )
            if response.status_code not in [200, 201]:
                print_red(
                    f"\nFailed to upload {local_file_path} to {sharepoint_file_path}: {response.json()}"
                )
    def extract_timestamped_file(self, files):
        """Finds the only .docx file with a timestamp in its name."""
        for filename in files:
            if filename.endswith(".docx") and re.search(r"\w+_\d{2}_\d{4}_\d{2}HR-\d{2}MIN", filename):
                return filename
        return None

    def upload_final_files(self):
        """Upload all files and subfolders from local directories to SharePoint, preserving structure."""
        print_yellow("Uploading files to SharePoint...")

        # Only process first-level directories inside AutoReports/Output/
        for folder_name in os.listdir(self.local_root):
            local_folder_path = os.path.join(self.local_root, folder_name)

            # Ensure it's a directory
            if not os.path.isdir(local_folder_path):
                continue  # Skip if it's not a directory

            # List all files in the local folder
            files = os.listdir(local_folder_path)

            # Find the timestamped .docx file
            final_docx_file = self.extract_timestamped_file(files)
            if not final_docx_file:
                print_red(f"No timestamped .docx file found in {local_folder_path}")
                continue

            # Create a folder named after the timestamped .docx file (without .docx extension)
            new_folder_name = os.path.splitext(final_docx_file)[0]
            new_folder_path = os.path.join(local_folder_path, new_folder_name)
            os.makedirs(new_folder_path, exist_ok=True)

             # Move all other files into the new folder (excluding the timestamped docx)
            for file in files:
                if file != final_docx_file:
                    shutil.move(os.path.join(local_folder_path, file), new_folder_path)

            print_green(f"Moved all files into '{new_folder_name}', keeping '{final_docx_file}' in 'report' folder.")


            # Extract school ID (everything before the first underscore)
            school_id = folder_name.split("_")[0]  # Extract school ID from folder name

            #print(f"Processing local folder: {folder_name}, Extracted school ID: {school_id}")

            # Check if the corresponding SharePoint folder exists
            existing_folder_path = self.find_sharepoint_folder_by_id(school_id)

            if existing_folder_path:
                #print(f"Found existing SharePoint folder: {existing_folder_path}")
                sharepoint_folder_path = existing_folder_path
            else:
                # Construct the new SharePoint folder path
                sharepoint_folder_path = os.path.join(self.sharepoint_root_folder, folder_name).replace("\\", "/")
                #print(f"No existing folder found. Creating new SharePoint folder: {sharepoint_folder_path}")

                # Create the folder structure in SharePoint
                self.create_sharepoint_folder(sharepoint_folder_path)

            # Ensure a 'report' subfolder is created inside the SharePoint folder
            report_folder_path = os.path.join(sharepoint_folder_path, "report").replace("\\", "/")

            if not self.file_exists_in_sharepoint(report_folder_path):
                self.create_sharepoint_folder(report_folder_path)

            # Upload everything inside the local school folder into the 'report' subfolder
            self.upload_folder_recursive(local_folder_path, report_folder_path)

        print_green("All files and subfolders uploaded successfully.")

    def upload_folder_recursive(self, local_path, sharepoint_path):
        """Recursively upload all files and folders from local_path to sharepoint_path, skipping .Rmd, .log, and 'Latex'."""
        for item in os.listdir(local_path):
            local_item_path = os.path.join(local_path, item)
            sharepoint_item_path = os.path.join(sharepoint_path, item).replace("\\", "/")

            # Skip the 'Latex' folder (case-insensitive)
            if item.lower() == "latex":
                print(f"Skipping Latex folder: {local_item_path}")
                continue

            if os.path.isdir(local_item_path):
                # If it's a directory, create it in SharePoint (if not exists) and recurse
                if not self.file_exists_in_sharepoint(sharepoint_item_path):
                    #print(f"Creating SharePoint folder: {sharepoint_item_path}")
                    self.create_sharepoint_folder(sharepoint_item_path)
                
                # Recursively upload files inside the folder
                self.upload_folder_recursive(local_item_path, sharepoint_item_path)

            else:
                # Skip files ending in .Rmd or .log
                if local_item_path.endswith((".Rmd", ".log")):
                    #print(f"Skipping file: {local_item_path}")
                    continue

                # If it's a file, upload it
                if self.file_exists_in_sharepoint(sharepoint_item_path):
                    print_yellow(f"File {sharepoint_item_path} already exists, replacing with new version.")

                #print(f"Uploading {local_item_path} to {sharepoint_item_path}")
                self.upload_file_to_sharepoint(local_item_path, sharepoint_item_path)




    def find_sharepoint_folder_by_id(self, school_id):
        """Find a SharePoint folder by school ID inside 'Final_Report_Documents'."""
        url = f"https://graph.microsoft.com/v1.0/sites/{self.site_id}/drives/{self.drive_id}/root:/Final_Report_Documents:/children"
        headers = {"Authorization": f"Bearer {self.access_token}"}
        response = requests.get(url, headers=headers, verify=self.ssl_certificate_path)

        if response.status_code == 200:
            items = response.json().get("value", [])
            #print("Folders found in 'Final_Report_Documents':", [item["name"] for item in items])  # Debugging output

            for item in items:
                # Ensure the item is a folder
                if "folder" in item and "_" in item["name"]:
                    folder_id = item["name"].split("_")[0]  # Extract the first part (school_id)
                    if folder_id == school_id:
                        return f"/Final_Report_Documents/{item['name']}"

        return None

