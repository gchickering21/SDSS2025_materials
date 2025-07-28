import os

from scripts.logging_config import root_logger


def _get_location_message(bucket_name, s3_folder, filename):
    """
    This method performs string operations to assist other methods in error messaging

    :param bucket_name: (str) name of the S3 bucket
    :param s3_folder: (str) name of folder in S3
    :param filename: (str) file to download
    """
    location_message = bucket_name
    if len(s3_folder) > 0 or len(filename) > 0:
        location_message += f" with prefix {s3_folder}{filename}"
    return location_message


def get_s3_filenames(s3_client, bucket_name, s3_folder, filename):
    """
    This method retrieves a list of objects from S3 and outputs an error if nothing is returned.

    :param bucket_name: (str) name of the S3 bucket
    :param s3_folder: (str) name of folder in S3
    :param filename: (str) file to download
    """
    location_message = _get_location_message(bucket_name, s3_folder, filename)

    # Retrieve S3 objects list based on inputs
    if len(s3_folder) > 0 or len(filename) > 0:
        prefix = f"{s3_folder}{filename}"
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    else:
        response = s3_client.list_objects_v2(Bucket=bucket_name)

    # Output error if nothing is returned
    if "Contents" in response:
        return response
    else:
        print(f"No objects found in {location_message}")
        return None


def download_file(s3_client, bucket_name, filename, s3_folder="", output_folder=""):
    """
    Download file from a specified S3 bucket and folder into local output folder.

    :param bucket_name: (str) name of the S3 bucket
    :param s3_folder: (str) name of folder in S3 (each folder must be followed by a '/')
    :param filename: (str) file to download
    :param output_folder: (str) path to the local output folder where files will be downloaded
    """
    location_message = _get_location_message(bucket_name, s3_folder, filename)
    response = get_s3_filenames(s3_client, bucket_name, s3_folder, filename)

    # Check number of items in response
    if response is None or len(response["Contents"]) == 0:
        root_logger.warning(f"No objects found in {location_message}.")
    elif len(response["Contents"]) > 1:
        root_logger.info(f"More than 1 file found in {location_message}.")
    else:
        # Download file
        try:
            key = response["Contents"][0]["Key"]
            download_path = os.path.join(output_folder, key[len(s3_folder) :])
            if not os.path.exists(download_path):
                s3_client.download_file(bucket_name, key, download_path)
                root_logger.info(f"Downloaded {key} to {download_path}")
            else:
                root_logger.info(f"File already exists: {key}")
        except Exception as e:
            root_logger.error(f"Error downloading files from S3: {e}")


def download_all_audio_files(s3_client, bucket_name, s3_folder="", output_folder=""):
    """
    Download only .mp3 and .mp4 files from the base folder of an S3 bucket.

    :param s3_client: (boto3.client) S3 client object
    :param bucket_name: (str) name of the S3 bucket
    :param s3_folder: (str) name of folder in S3 (must end with '/')
    :param output_folder: (str) path to the local output folder where files will be downloaded
    """
    root_logger.info(
        f"Downloading .mp3 and .mp4 files from {bucket_name} with prefix {s3_folder} to {output_folder}"
    )

    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=s3_folder)

    if "Contents" not in response:
        root_logger.warning("No S3 files found")
        return

    # Download files from the base folder only
    for obj in response["Contents"]:
        key = obj["Key"]
        # Ensure file is directly in the base folder (no additional '/')
        if key.endswith((".mp3", ".mp4")) and key.count("/") <= s3_folder.count("/"):
            download_path = os.path.join(output_folder, os.path.basename(key))
            os.makedirs(os.path.dirname(download_path), exist_ok=True)

            if not os.path.exists(download_path):
                s3_client.download_file(bucket_name, key, download_path)
                root_logger.info(f"Downloaded {key} to {download_path}")
            else:
                root_logger.info(f"File already exists: {key}")
        #else:
            #root_logger.info(f"Skipping file not in base folder: {key}")

    return


def move_non_audio_files(
    s3_client,
    bucket_name,
    source_folder="audio_files/",
    destination_folder="non_audio_files/",
):
    """
    Move all non .mp3 or .mp4 files from the source folder to the destination folder in the specified S3 bucket.

    :param s3_client: (boto3.client) S3 client
    :param bucket_name: (str) name of the S3 bucket
    :param source_folder: (str) name of the source folder in S3
    :param destination_folder: (str) name of the destination folder in S3
    """
    # List objects in the source folder
    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=source_folder)

    if "Contents" not in response:
        print(f"No objects found in {source_folder}")
        return

    for obj in response["Contents"]:
        key = obj["Key"]
        if not key.endswith("/") and not (key.endswith(".mp3") or key.endswith(".mp4")):
            # Define the new key for the destination folder
            new_key = key.replace(source_folder, destination_folder, 1)

            try:
                # Copy the object to the new location
                s3_client.copy_object(
                    Bucket=bucket_name,
                    CopySource={"Bucket": bucket_name, "Key": key},
                    Key=new_key,
                )
                root_logger.info(f"Copied {key} to {new_key}")

                # Delete the original object
                s3_client.delete_object(Bucket=bucket_name, Key=key)
                root_logger.info(f"Deleted {key} from {source_folder}")
            except Exception as e:
                root_logger.error(f"Error moving {key} to {new_key}: {e}")


# def main():
# Setup
# config = Config("resources/config.ini")
# aws_config = config.get_aws_config()
# s3_client = lib.get_s3_client(aws_config)

# # Download
# s3_bucket_name = "il-empower-transcripts"
# processing_folder = "tagged_transcripts/"
# download_all(s3_client, s3_bucket_name, processing_folder, "tagged_transcripts/")


# if __name__ == "__main__":
#     main()
