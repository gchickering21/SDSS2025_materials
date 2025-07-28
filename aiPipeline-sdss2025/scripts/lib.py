import glob
import os
import shutil

import boto3
import psycopg2
from botocore.exceptions import ClientError
from openai import AzureOpenAI

from scripts.logging_config import root_logger


def get_s3_client(aws_config):
    """
    Get boto3 client connecting to S3

    :param aws_config: configuration object
    :returns: s3_client
    """
    s3_client = boto3.client(
        "s3",
        aws_access_key_id=aws_config["aws_access_key_id"],
        aws_secret_access_key=aws_config["aws_secret_access_key"]
    )
    return s3_client


def get_database_connection(db_config):
    """
    Get psycopg2 database connection object

    :param db_config: configuration object
    :returns: connection
    """
    ##TODO: MOVE TO CONFIG
    connection = psycopg2.connect(
        user="metabase_user",
        password=db_config["db_pswd"],
        host="il-empower-eps-db.ccycbr9s6qwf.us-east-1.rds.amazonaws.com",
        port="5432",
        database="eps_reporting_db",
    )
    return connection


def get_gpt_client(vault_url, api_key, azure_endpoint, api_version):
    """
    Get gpt object from getAI_utils

    :param azure_config: configuration object
    :returns: gpt
    """

    try:
        openai_client = AzureOpenAI(
            azure_endpoint=azure_endpoint,
            api_key=api_key,
            api_version=api_version,
        )
        return openai_client
    except ValueError as e:
        print("Unable to set api key and/or azure_endpoint")
        root_logger.warning("Unable to connect to ")
        raise e


############################# DEALING WITH CLEARING FILES FROM FOLDERS ###############################


def clear_local_folders():
    """
    Clear out the specified local folders.
    """
    folders = {
        "ai_findings": "ai_findings/",
        "audio_files": "audio_files/",
        "audio_files_processed": "audio_files_processed/",
        "audio_files_not_processed": "audio_files_not_processed/",
        "diarized_transcribed_text": "diarized_transcribed_text/",
        "tagged_transcripts": "tagged_transcripts/",
        "test_output": "test_output/",
        "word_diarized_transcripts": "word_diarized_transcripts/",
        "word_transcripts": "word_transcripts/",
    }

    for name, folder_path in folders.items():
        try:
            # Clear and recreate the folder
            if os.path.exists(folder_path):
                shutil.rmtree(folder_path)
            os.makedirs(folder_path)
            root_logger.info(f"Cleared {name} folder: {folder_path}")
        except Exception as e:
            root_logger.error(f"Failed to clear {name} folder at {folder_path}: {e}")


def clear_folder(folder_path):
    """Deletes all files in the specified folder."""
    if not os.path.isdir(folder_path):
        print(f"{folder_path} is not a valid directory.")
        return

    # Get a list of all files in the folder
    files = glob.glob(os.path.join(folder_path, "*"))

    for file in files:
        try:
            if os.path.isfile(file):
                os.remove(file)
                root_logger.info(f"Removed file: {file}")
            elif os.path.isdir(file):
                root_logger.info(f"Skipped directory: {file}")
        except Exception as e:
            root_logger.warning(f"Error removing {file}: {e}")

    root_logger.info("All files have been removed.")


def move_processed_audio_files(s3_client, file_status=None):
    ##TODO: MOVE TO CONFIG
    """
    Moves all files from the 'audio_files' folder to the 'processed_audio_files' folder within the same S3 bucket.
    """
    # Define the local folder containing processed audio files
    local_folder = "audio_files_processed"

    try:
        # Loop through all files in the local 'audio_files_processed' folder
        for filename in os.listdir(local_folder):
            # Construct source and destination keys for S3
            source_key = filename
            destination_key = f"processed_audio_files/{filename}"

            # Move the file in S3 from the source folder to the destination folder
            move_s3_file(
                s3_client, "il-empower-audiofiles-year2", source_key, destination_key
            )

            # Verify if the file exists in the destination folder
            response = s3_client.list_objects_v2(
                Bucket="il-empower-audiofiles-year2", Prefix=destination_key
            )
            file_exists = any(
                obj["Key"] == destination_key for obj in response.get("Contents", [])
            )

            # Update the tracking dictionary only if the file exists
            if file_exists and file_status:
                filename = filename.split(".")[0]
                file_status[filename]["moved_audio_files"] = True

            root_logger.info(
                "All specified audio files have moved to processed bucket in s3"
            )

    except ClientError as e:
        root_logger.error(f"Failed to move over processed audio files: {e}")

    return file_status


def move_audio_files_not_processed(s3_client, filename=None, file_status=None):
    ##TODO: MOVE TO CONFIG
    """
    Moves all files from the base folder to the 'processed_audio_files' folder within the same S3 bucket.
    """

    try:
        # Construct source and destination keys for S3
        source_key = f"{filename}"
        destination_key = f"audio_files_not_processed/{filename}"

        # Move the file in S3 from the source folder to the destination folder
        move_s3_file(
            s3_client, "il-empower-audiofiles-year2", source_key, destination_key
        )

        # Verify if the file exists in the destination folder
        response = s3_client.list_objects_v2(
            Bucket="il-empower-audiofiles-year2", Prefix=destination_key
        )
        file_exists = any(
            obj["Key"] == destination_key for obj in response.get("Contents", [])
        )

        # Update the tracking dictionary only if the file exists
        if file_exists and file_status:
            file_status[filename]["moved_audio_files"] = True

    except ClientError as e:
        root_logger.error(f"Failed to move over processed audio files: {e}")

    root_logger.info("All specified audio files have moved to processed bucket in s3")

    return file_status


def move_processed_file(
    filename: str,
    source_folder: str = None,
    processed_folder: str = None,
):
    """
    Moves the specified file from the source folder to the processed folder.
    If the processed folder does not exist, it is created.
    """
    try:
        # Ensure the processed folder exists
        os.makedirs(processed_folder, exist_ok=True)

        # Construct full file paths
        source_path = os.path.join(source_folder, filename)
        destination_path = os.path.join(processed_folder, filename)

        # Move the file
        shutil.move(source_path, destination_path)
        root_logger.info(f"Moved {filename} to {processed_folder}")
    except Exception as e:
        root_logger.warning(f"Error moving file {filename}: {e}")


def move_s3_file(s3_client, bucket_name, source_key, destination_key):
    try:
        # Copy the object
        s3_client.copy_object(
            Bucket=bucket_name,
            Key=destination_key,
            CopySource={"Bucket": bucket_name, "Key": source_key},
        )
        root_logger.info(f"Successfully copied {source_key} to {destination_key}")

        # Delete the original object to simulate a "move"
        s3_client.delete_object(Bucket=bucket_name, Key=source_key)
        root_logger.info(f"Successfully deleted {source_key}")

    except ClientError as e:
        root_logger.error(f"Error moving {source_key} to {destination_key}: {e}")


def upload_files_to_s3(
    s3_client, file_status=None, s3_transcript_bucket="il-empower-transcripts"
):
    """
    Upload all files from specified local folders to their respective folders in S3,
    excluding .DS_Store files.
    """
    # Define folder mappings directly within the function
    folder_mappings = {
        "word_transcripts": "word_transcripts",
        "word_diarized_transcripts": "word_diarized_transcripts",
        "tagged_transcripts": "tagged_transcripts",
        "ai_findings": "ai_findings",
    }
    try:
        for local_folder, s3_folder in folder_mappings.items():
            # Get all files in the local folder, excluding .DS_Store
            files = [
                f for f in glob.glob(f"{local_folder}/*") if not f.endswith(".DS_Store")
            ]
            for file in files:
                filename = os.path.basename(file)
                s3_key = f"{s3_folder}/{filename}"  # S3 key for the specified S3 folder
                s3_client.upload_file(file, s3_transcript_bucket, s3_key)
                root_logger.info(
                    f"Uploaded {filename} to {s3_key} in bucket {s3_transcript_bucket}"
                )

        # If files all got uploaded now go through and mark them in the tracking dictionary
        for file_name in file_status:
            file_status[file_name]["uploaded_s3_files"] = True

    except ClientError as e:
        root_logger.error(f"Failed to upload {filename} to {s3_key}: {e}")

    root_logger.info("All specified files have been uploaded to S3.")
    return file_status
