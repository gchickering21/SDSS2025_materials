import os
import time

from dotenv import load_dotenv

import scripts.lib as lib
import scripts.s3_manager as s3_manager
import scripts.upload_findings_to_db as db_upload
from scripts.audio_conversion import Transcriber
from scripts.config import Config
from scripts.logging_config import root_logger
from scripts.parse_transcript import produce_ai_findings
from scripts.sharepoint_automation import SharepointAuthentication
from scripts.transcript_diarization import Diarizer
from scripts.transcript_tagging import Transcript_Tagging


def run_ai_pipeline():
    load_dotenv()
    # print(ssl.get_default_verify_paths())
    # Establish clients - AWS
    root_logger.info("starting batch run")
    config = Config("resources/config_template.ini")

    aws_client_established = False
    azure_client_established = False
    db_connection_established = False
    sharepoint_connection_established = False

    try:
        aws_config = config.get_aws_config()
        s3_client = lib.get_s3_client(aws_config)
        root_logger.info("AWS client established")
        aws_client_established = True
    except Exception as e:
        root_logger.error(f"Error establishing AWS client: {e}")

    # Azure
    try:
        vault_url, api_key, azure_endpoint, api_version = config.get_azure_config()
        gpt_client = lib.get_gpt_client(vault_url, api_key, azure_endpoint, api_version)
        root_logger.info("Azure client established")
        azure_client_established = True
    except Exception as e:
        root_logger.error(f"Error establishing Azure client: {e}")

    # Database
    try:
        db_config = config.get_database_config()
        connection = lib.get_database_connection(db_config)
        # cursor = connection.cursor()
        root_logger.info("Database connection established")
        db_connection_established = True
    except Exception as e:
        root_logger.error(f"Error establishing database connection: {e}")

    # Sharepoint
    try:
        sharepoint_config = config.get_sharepoint_config()
        sharepoint_manager = SharepointAuthentication(sharepoint_config)
        sharepoint_manager.initialize_sharepoint()
        root_logger.info("Sharepoint connection established")
        sharepoint_connection_established = True
    except Exception as e:
        root_logger.error(f"Error establishing sharepoint connection: {e}")

    # Clear local folders only if all clients are established
    if (
        aws_client_established
        and azure_client_established
        and db_connection_established
        and sharepoint_connection_established
    ):
        lib.clear_local_folders()
    else:
        root_logger.error(
            "Not all clients were established successfully. Skipping clearing local folders."
        )
        return
    # Dictionary to track file processing status
    file_status = {}

    try:
        # Move non-audio files to a separate folder
        # # Download files
        s3_manager.download_all_audio_files(
            s3_client, "S3-BUCKET_NAME", "", "audio_files/"
        )
        audio_files_path = "audio_files/"
        # Check if any .mp3 or .mp4 files were downloaded
        audio_files_found = False
        for file in os.listdir(audio_files_path):
            if file.lower().endswith((".mp3", ".mp4")):
                audio_files_found = True
                break  # Stop searching as we found an audio file

        # If no audio files are found, skip the rest of the processing
        if not audio_files_found:
            root_logger.warning("No .mp3 or .mp4 files found. Exiting batch run.")
            return  # Exit the main function

        for file in os.listdir(audio_files_path):
            print(file)
            # Check if the file has a supported extension
            if not file.lower().endswith((".mp3", ".mp4")):
                # Log a warning if the file cannot be processed
                root_logger.warning(
                    f"File '{file}' has an unsupported extension and cannot be processed."
                )
            else:
                result = file.split(".")[0]
                file_keys = db_upload.get_columns_from_db(
                    conn=connection, filename=file
                )
                file_status[result] = file_keys if file_keys else {}
                ## Check to handle if filename in s3 does not match any filenames in db
                ##THIS WILL HAPPEN IF AUDIO FILE UPLOAD FORM NAME DOES NOT MATCH AUDIO FILE NAME IN S3
                if not file_keys:
                    file_status[result].update(
                        {
                            "downloaded": True,
                            "transcribed": False,
                            "diarized": False,
                            "tagged": False,
                            "ai_findings_produced": False,
                            "ai_findings_to_db": False,
                            "uploaded_s3_files": False,
                            "sent_to_sharepoint": False,
                            "moved_audio_files": False,
                        }
                    )
                    root_logger.error(
                        "Correct Audio Form Missing: Audio file name does not match any filenames in the database"
                    )
                    lib.move_processed_file(
                        file,
                        source_folder="audio_files",
                        processed_folder="audio_files_not_processed",
                    )
                    file_status = lib.move_audio_files_not_processed(
                        s3_client, filename=file, file_status=file_status
                    )
                else:
                    # Initialize file_status[result] with file_keys if available, or an empty dict
                    file_status[result] = file_keys if file_keys else {}
                    # Append additional keys and default values
                    file_status[result].update(
                        {
                            "downloaded": True,
                            "transcribed": False,
                            "diarized": False,
                            "tagged": False,
                            "ai_findings_produced": False,
                            "ai_findings_to_db": False,
                            "uploaded_s3_files": False,
                            "sent_to_sharepoint": False,
                            "moved_audio_files": False,
                        }
                    )

        transcriber = Transcriber(gpt_client)
        try:
            file_status = transcriber.process_all_audio_files(file_status=file_status)
            root_logger.info("Transcription process completed for all files")
        except Exception as e:
            root_logger.error(f"Error during transcription process: {e}")

        # ## Diarization process
        diarizer = Diarizer()
        try:
            file_status = diarizer.process_and_save_diarized_files(
                file_status=file_status
            )
            root_logger.info(f"Diarization completed for {file}")
        except Exception as e:
            root_logger.error(f"Error during diarization process: {e}")

        ## Tagging process
        tagger = Transcript_Tagging()
        try:
            file_status = tagger.run_transcript_tagging(file_status=file_status)
            root_logger.info(f"Tagging completed for {file}")
        except Exception as e:
            root_logger.error(f"Error during tagging process: {e}")

        ## AI findings process
        try:
            file_status = produce_ai_findings(gpt_client, file_status=file_status)
            root_logger.info(f"AI findings processed for {file}")
        except Exception as e:
            root_logger.error(f"Error during AI findings process: {e}")

        ## Write AI findings to DB
        try:
            db_upload.upload_all_ai_findings_to_db(
                file_status=file_status, conn=connection
            )
            root_logger.info(f"AI findings written to database for {file}")
        except Exception as e:
            root_logger.error(f"Error during AI findings process: {e}")

    except Exception as e:
        root_logger.error(f"An error occurred during app.py file processing: {e}")

    else:
        #### Upload successfully processed files to S3
        try:
            file_status = lib.upload_files_to_s3(s3_client, file_status=file_status)
            root_logger.info("Completed uploading files to S3")
        except Exception as s3_error:
            root_logger.error(f"Error during S3 upload operations: {s3_error}")

        try:
            file_status = sharepoint_manager.upload_final_files_to_sharepoint(
                file_status
            )
            root_logger.info("Completed sending files to sharepoint")
        except Exception as sharepoint_error:
            root_logger.error(f"Error during S3 upload operations: {sharepoint_error}")

        # Move processed audio files within S3 bucket after upload
        try:
            file_status = lib.move_processed_audio_files(
                s3_client, file_status=file_status
            )
            root_logger.info("Completed moving files within S3 bucket")
        except Exception as move_error:
            root_logger.error(f"Error moving files in S3: {move_error}")

        ## Write file_status values to database at the end of it all
        try:
            db_upload.upload_tracking_to_db(file_status=file_status, conn=connection)
            root_logger.info(
                "Completed writing file status to DB for Tracking Purposes"
            )
        except Exception as move_error:
            root_logger.error(
                f"Error writing file status to DB for Tracking Purposes: {move_error}"
            )

        print(file_status)
        root_logger.info(f"File Status For Entire Run: {file_status}")


def main():
    run_ai_pipeline()


if __name__ == "__main__":
    main()
