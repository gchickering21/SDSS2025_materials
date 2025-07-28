import configparser
import os

##Note: This is how we connect to OpenAI-API and recieve Azure Credentials , for security reasons this function could not be included or displayed
from genAI_utils.air_genai_helper import initialize_urls_and_key


class Config:
    parser = None

    def __init__(self, config_file):
        parser = configparser.ConfigParser()
        parser.read(config_file)
        self.parser = parser

    def get_azure_credentials_from_genAI_utils(self):
        stack = os.environ.get("DCK_STACK")
        env = "local" if stack is None else "aks"
        try:
            if env == "local":
                vault_url, api_key, azure_endpoint = initialize_urls_and_key(
                    "ps", "northcentralus"
                )
            else:
                vault_url, api_key, azure_endpoint = initialize_urls_and_key(
                    "ps", "eastus2"
                )
            return vault_url, api_key, azure_endpoint
        except ValueError as e:
            print(e)
            return None

    def get_azure_config(self):
        """
        Returns the Azure configuration set from 'resources/config.ini'
        """
        azure_config = self.parser._sections["AZURE"]
        api_version = azure_config.get("api_version")
        vault_url, api_key, azure_endpoint = (
            self.get_azure_credentials_from_genAI_utils()
        )
        return vault_url, api_key, azure_endpoint, api_version

    def get_aws_config(self):
        """
        Returns the AWS configuration set from 'resources/config.ini'
        """
        section = self.parser._sections["AWS"]
        section["aws_access_key_id"] = os.environ.get("AWS_ACCESS_KEY_ID")
        section["aws_secret_access_key"] = os.environ.get("AWS_SECRET_ACCESS_KEY")
        return section

    def get_database_config(self):
        """
        Returns the DB configuration set from 'resources/config.ini'
        """
        section = self.parser._sections["DATABASE"]
        section["db_pswd"] = os.environ.get("DB_PSWD")
        return section

    def get_sharepoint_config(self):
        """
        Returns the Sharepoint configuration set from 'resources/config.ini'
        """
        return self.parser._sections["SHAREPOINT"]


