import os
import pathlib
import shutil
import subprocess
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

import assemblyai as aai
import ffmpeg
from docx import Document
from natsort import natsorted
from pydub import AudioSegment

from scripts.logging_config import root_logger

# Global variables for rate limiting
HITS_PER_MINUTE = 10
RATE_LIMIT_WINDOW = 60  # 60 seconds
user_hit_timestamps = {}  # Dictionary to store hit timestamps for each user


class Transcriber:
    def __init__(self, gpt_client):
        pass
        self.whisper_client = gpt_client

    def replace_extensions(self, filename, extensions_to_replace, new_extension):
        for ext in extensions_to_replace:
            filename = filename.replace(ext, new_extension)
        return filename

    def convert_file(self, input_file):
        input_path = f"audio_files/{input_file}"
        output_file = input_file.split(pathlib.Path(input_file).suffix)[0] + ".ogg"
        output_path = f"audio_files/{output_file}"
        try:
            ffmpeg.input(input_path).output(output_path, format="ogg").run(
                overwrite_output=True
            )
            root_logger.info(f"Conversion to {output_file} successful!")
            return output_file
        except ffmpeg.Error as e:
            root_logger.warning(f"An error occurred: {e}")
            return input_file

    def extract_audio(self, input_file):
        output_file = "NO_VIDEO-" + input_file
        extensions_to_replace = [".mp3", ".mp4"]
        new_extension = ".m4a"
        output_file = self.replace_extensions(
            output_file, extensions_to_replace, new_extension
        )
        input_path = os.path.join("audio_files", input_file)
        output_path = os.path.join("audio_files", output_file)
        stack = os.environ.get("DCK_STACK")
        environment = "local" if stack is None else "aks"
        # Absolute path to ffmpeg
        if environment == "local":
            ffmpeg_cmd = "ffmpeg"
        else:
            ffmpeg_cmd = "/usr/bin/ffmpeg"
        try:
            subprocess.run(
                [ffmpeg_cmd, "-i", input_path, "-vn", "-acodec", "copy", output_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,  # This will raise an exception if the command fails
            )
        except subprocess.CalledProcessError as e:
            # Log or handle the error appropriately
            print(f"Error occurred: {e.stderr.decode()}")
            return None
        # print(output_file)
        return output_file

    def get_file_duration(self, file_path):
        """Get the duration of the file using ffprobe."""
        result = subprocess.run(
            [
                "ffprobe",
                "-v",
                "error",
                "-show_entries",
                "format=duration",
                "-of",
                "default=noprint_wrappers=1:nokey=1",
                file_path,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        return float(result.stdout)

    def split_chunk(self, start_time, chunk_duration, file_path, output_file):
        """Split the file into chunks using ffmpeg."""

        root_logger.info(
            f"Starting split for {output_file} from {start_time}s to {start_time + chunk_duration}s"
        )

        subprocess.run(
            [
                "ffmpeg",
                "-i",
                file_path,
                "-ss",
                str(start_time),
                "-t",
                str(chunk_duration),
                "-c",
                "copy",
                output_file,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        root_logger.info(
            f"Completed split for {output_file} from {start_time}s to {start_time + chunk_duration}s"
        )

    def split_file(self, file_path, file_size, chunk_size=25 * 1024 * 1024):
        # Calculate the number of chunks
        num_chunks = file_size // chunk_size
        if file_size % chunk_size:
            num_chunks += 1

        # Get the duration of the file using ffprobe
        duration = self.get_file_duration(file_path)

        # Calculate the duration for each chunk
        chunk_duration = duration / num_chunks
        base_name, ext = os.path.splitext(file_path)

        # Prepare tasks for parallel execution
        tasks = []
        with ThreadPoolExecutor() as executor:
            for i in range(num_chunks):
                root_logger.debug(f"{(i+1)/num_chunks:.2%} DONE ....")
                start_time = i * chunk_duration
                output_file = f"{base_name}_part{i + 1}{ext}"
                tasks.append(
                    executor.submit(
                        self.split_chunk,
                        start_time,
                        chunk_duration,
                        file_path,
                        output_file,
                    )
                )

            # Wait for all tasks to complete
            for future in as_completed(tasks):
                future.result()  # Raises exception if the task failed

        root_logger.info("Splitting completed.")

    def validate_batchfiles(
        self, chunk_limit=25 * 1024 * 1024, new_chunk_size=12 * 1024 * 1024
    ):
        files = [
            f
            for f in os.listdir("audio_files/")
            if os.path.isfile(os.path.join("audio_files/", f))
        ]
        file_sizes = {
            file: os.path.getsize(os.path.join("audio_files/", file)) for file in files
        }
        large_files = [
            file
            for file, size in file_sizes.items()
            if size > chunk_limit and "part" in file
        ]
        for lf in large_files:
            file = "audio_files/" + lf
            self.split_file(file, file_sizes[lf], new_chunk_size)
            os.remove(file)

    def get_splits(self, filename):
        path = "audio_files/"
        # List to hold the filenames
        part_files = []

        # Iterate over all files in the directory
        for file in os.listdir(path):
            if "_part" in file and filename.split(".")[0] in file:
                part_files.append(file)

        # Print the filenames
        return part_files

    # Function to send transcription request with retry mechanism
    def send_transcription_request_with_retry(self, audio_file_path):
        retry_count = 0
        root_logger.info(
            f"Running send_transcription_request_with_retry RETRY: {retry_count}"
        )
        retry_delay = 20
        while retry_count < 10:
            try:
                # Send transcription request
                with open(audio_file_path, "rb") as audio_file:
                    transcription = self.whisper_client.audio.transcriptions.create(
                        model="whisper", language="en", temperature=0, file=audio_file
                    )
                return transcription.text
            except Exception as e:
                root_logger.warning(f"Error occurred: {e}")
                root_logger.warning(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
                retry_count += 1
        # If retries exhausted, mark the request as failed
        root_logger.warning(
            "Failed to send transcription request after maximum retries."
        )
        return None

    def whisper_transcription(self, file):
        root_logger.info("Running whisper_transcription ...")
        file_path = "audio_files/" + file
        file_size = os.path.getsize(file_path)
        audio = AudioSegment.from_file(file_path)
        # Get the duration in milliseconds and convert to minutes
        duration_in_minutes = len(audio) / (1000 * 60)
        root_logger.info(f"Duration: {duration_in_minutes:.2f} minutes")
        root_logger.info(file_size)
        if file_size < 25165000:
            return (
                self.send_transcription_request_with_retry("audio_files/" + file),
                duration_in_minutes,
            )
        else:
            root_logger.info("Splitting Files ...")
            self.split_file(file_path, file_size)
            root_logger.info("Validating Files ...")
            self.validate_batchfiles()
            file_list = self.get_splits(file)
            transcription_final = []
            for file in natsorted(file_list):
                try:
                    transcription_text = self.send_transcription_request_with_retry(
                        "audio_files/" + file
                    )
                    if transcription_text:
                        transcription_final.append(transcription_text)
                        root_logger.info(f"Processed file: {file}")
                except Exception as e:
                    root_logger.warning(f"ERROR processing file {file}: {e}")

            transcription_final = " ".join(transcription_final)

        return transcription_final, duration_in_minutes

    def remove_repeats(self, text):
        """
        This function will first check repeated sentences then check repeated words
        """
        sentences = text.split(". ")
        unique_sentences = []

        for sentence in sentences:
            if unique_sentences and unique_sentences[-1] == sentence:
                continue
            unique_sentences.append(sentence)

        cleaned_text = ". ".join(unique_sentences)

        words = cleaned_text.split()
        unique_words = []

        for i, word in enumerate(words):
            if i > 0 and words[i - 1] == word:
                continue
            unique_words.append(word)

        final_text = " ".join(unique_words)
        return final_text

    def convert_to_word(self, filename, transcription):
        transcription_cleaned = self.remove_repeats(transcription)
        document = Document()
        document.add_paragraph(transcription_cleaned)
        base_name = os.path.splitext(filename)[0]
        transcribed_name = f"transcribed_{base_name}.docx"
        transcribed_path = os.path.join("word_transcripts", transcribed_name)
        document.save(transcribed_path)

    def cleanup_part_files(self, directory: str):
        """
        Deletes all files containing '_part' in the specified directory.
        """
        try:
            part_files = [f for f in os.listdir(directory) if "_part" in f]
            for file in part_files:
                file_path = os.path.join(directory, file)
                os.remove(file_path)
                root_logger.info(f"Deleted {file_path}")
            root_logger.info("Cleanup completed: all '_part' files deleted.")
        except Exception as e:
            root_logger.warning(f"Error during cleanup: {e}")

    def move_processed_file(
        self,
        filename: str,
        source_folder: str = "audio_files",
        processed_folder: str = "audio_files_processed",
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

    def process_all_audio_files(
        self,
        file_status=None,
        source_folder: str = "audio_files",
        processed_folder: str = "audio_files_processed",
    ):
        """
        Loops through all files in the source folder, transcribes them, creates Word documents,
        cleans up temporary _part files, and moves the original audio files to the processed folder.
        """
        # List all files in the source folder
        audio_files = [
            f
            for f in os.listdir(source_folder)
            if os.path.isfile(os.path.join(source_folder, f))
            and f.lower().endswith((".mp3", ".mp4"))
        ]

        for file_path in audio_files:
            try:
                # Perform transcription and get the final transcription text and duration
                transcription_final, duration_in_minutes = self.whisper_transcription(
                    file_path
                )
                root_logger.info(f"Transcription for {file_path}:")
                root_logger.info(f"Duration: {duration_in_minutes} minutes")

                # Convert transcription to Word document
                self.convert_to_word(file_path, transcription_final)

                # Clean up temporary _part files
                self.cleanup_part_files("audio_files")

                # Move the processed audio file to the processed folder
                self.move_processed_file(file_path, source_folder, processed_folder)
                result = file_path.split(".")[0]
                file_status[result]["transcribed"] = True
                root_logger.info(f"Completed audio file processing for {file_path}\n")
            except Exception as e:
                root_logger.warning(f"Error audio file processing {file_path}: {e}")
        return file_status


# if __name__ == "__main__":
#     transcriber = Transcriber()
#     transcriber.process_all_audio_files()
