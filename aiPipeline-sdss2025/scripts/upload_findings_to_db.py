import os
from datetime import datetime

import pandas as pd
from psycopg2 import sql

from scripts.logging_config import root_logger


def get_columns_from_db(conn=None, filename=None):
    """
    Retrieve all columns for a specific record based on the filename from the 'audio_file_upload_form_year_2' table.

    :param conn: (psycopg2.connection) Database connection
    :param filename: (str) Filename to search for in the 'audio_file_upload_file_name' column
    :return: (dict) Dictionary of column names and their values for the matching record
    """

    if conn is None or filename is None:
        raise ValueError("Both 'conn' and 'filename' parameters are required")

    columns = ["id", "school_and_district_name", "rcdts", "audio_file_upload_type"]

    # Safely format the columns for the SQL query
    columns_str = ", ".join([f'"{col}"' for col in columns])

    query = f"""
    SELECT {columns_str}
    FROM audio_file_upload_form_year_2
    WHERE (REPLACE(REPLACE(LOWER(audio_file_upload_file_name), '_', '-'), ' ', '-') = %s)
    OR (CONCAT(REPLACE(REPLACE(LOWER(audio_file_upload_file_name), '_', '-'), ' ', '-'), '.mp3') = %s)
    OR (CONCAT(REPLACE(REPLACE(LOWER(audio_file_upload_file_name), '_', '-'), ' ', '-'), '.mp4') = %s)
    """
    try:
        with conn.cursor() as cursor:
            cursor.execute(query, (filename, filename, filename))
            record = cursor.fetchone()

            if record is None:
                root_logger.error(f"No record found for filename: {filename}")
                return None

            # Get column names from the cursor description
            column_names = [desc[0] for desc in cursor.description]

            # Create a dictionary of column names and their values
            record_dict = dict(zip(column_names, record))

            # Split 'school_and_district_name' into separate fields
            school_and_district = record_dict.pop("school_and_district_name", None)
            if school_and_district:
                try:
                    school_name, district_name = map(
                        str.strip, school_and_district.split("-", 1)
                    )
                    record_dict["school_name"] = school_name
                    record_dict["district_name"] = district_name
                except ValueError:
                    root_logger.error(
                        f"Invalid format for school_and_district_name: {school_and_district}"
                    )

            # Transform 'audio_file_upload_type'
            upload_type = record_dict.get("audio_file_upload_type")
            if upload_type:
                record_dict["audio_file_upload_type"] = upload_type.split()[0].lower()

            return record_dict

    except Exception as e:
        root_logger.error(f"Error retrieving record: {e}")
        return None


def upload_tracking_to_db(file_status=None, conn=None):
    """
    Upload tracking information to the database.

    Args:
        file_status (dict): Dictionary containing tracking data.
        conn: Active database connection object.

    Returns:
        None
    """
    if not file_status or not conn:
        raise ValueError("Both file_status and conn arguments are required.")

    # Get the current date and time
    current_time = datetime.now()

    for file_name, status_data in file_status.items():
        # Parse the necessary keys
        file_ids_id = status_data.get("id")  # Foreign key to another table
        file_run_date = current_time  # Current timestamp

        # Map keys to their respective database columns (excluding ai_tracking_id)
        columns = [
            "file_ids_id",
            "file_run_date",
            "downloaded",
            "transcribed",
            "diarized",
            "tagged",
            "ai_findings_produced",
            "ai_findings_to_db",
            "uploaded_s3_files",
            "sent_to_sharepoint",
            "moved_audio_files",
        ]
        values = [
            file_ids_id,
            file_run_date,
            status_data.get("downloaded"),
            status_data.get("transcribed"),
            status_data.get("diarized"),
            status_data.get("tagged"),
            status_data.get("ai_findings_produced"),
            status_data.get("ai_findings_to_db"),
            status_data.get("uploaded_s3_files"),
            status_data.get("sent_to_sharepoint"),
            status_data.get("moved_audio_files"),
        ]

        # Construct the SQL query
        query = f"""
        INSERT INTO ai_tracking_year_2 ({', '.join(columns)})
        VALUES ({', '.join(['%s'] * len(values))});
        """

        # Execute the query
        try:
            with conn.cursor() as cur:
                cur.execute(query, values)
            conn.commit()
            root_logger.info(
                f"Successfully uploaded tracking data for file: {file_name}"
            )
        except Exception as e:
            conn.rollback()
            root_logger.error(
                f"Failed to upload tracking data for file: {file_name}, Error: {e}"
            )


def upload_all_ai_findings_to_db(file_status=None, conn=None):
    """
    Upload all files from ai folder to database
    """
    folder_path = "ai_findings"
    try:
        # Filter files in the folder to only include those ending with .csv
        ai_files = [
            os.path.join(folder_path, file)
            for file in os.listdir(folder_path)
            if file.endswith(".csv")
        ]

        for file in ai_files:
            root_logger.info(f"Uploading {file} to database...")
            dataframe = pd.read_csv(file)
            if file.endswith(".csv"):
                ai_fp = os.path.splitext(os.path.basename(file))[0]
                clean_ai_fp = ai_fp.replace("ai_findings_", "")
            uploaded_successfully = upload_file_to_ai_findings(
                conn, dataframe, file_status[clean_ai_fp]
            )
            if uploaded_successfully:
                file_status[clean_ai_fp]["ai_findings_to_db"] = True

    except Exception as e:
        root_logger.error(f"Failed to upload {file} to database: {e}")

    return file_status


def upload_file_to_ai_findings(conn, dataframe, file_status_filename):
    try:
        uploaded_successfully = False
        with conn.cursor() as cursor:
            query = sql.SQL(
                """INSERT INTO ai_findings_year_2 (
                    file_ids_id,
                    file_run_date,
                    interview_type,
                    indicator_number,
                    standard_name,
                    indicator_name,
                    category,
                    content
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""  # Removed the extra comma
            )
            ai_date = datetime.now()
            for r in range(len(dataframe)):
                file_ids_id = file_status_filename["id"]
                file_run_date = ai_date
                interview_type = file_status_filename["audio_file_upload_type"]
                indicator_number = dataframe.iloc[r]["Indicator Number"]
                standard_name = dataframe.iloc[r]["Standard Name"]
                indicator_name = dataframe.iloc[r]["Indicator Name"]
                category = dataframe.iloc[r]["Category"]
                content = dataframe.iloc[r]["Content"]
                # Assign values from each row
                values = (
                    file_ids_id,
                    file_run_date,
                    interview_type,
                    indicator_number,
                    standard_name,
                    indicator_name,
                    category,
                    content,
                )
                # Execute sql Query
                cursor.execute(query, values)
            # Commit the transaction
            conn.commit()
        root_logger.info(f"Data uploaded successfully with foreign key {file_ids_id}")
        uploaded_successfully = True
        return uploaded_successfully
    except Exception as e:
        root_logger.error(f"Error uploading data: {e}")
        conn.rollback()
        return uploaded_successfully
