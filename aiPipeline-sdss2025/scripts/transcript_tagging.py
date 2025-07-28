import os
import re

import docx
import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer

from scripts.logging_config import root_logger


class Transcript_Tagging:
    def __init__(self, model_name="paraphrase-distilroberta-base-v2"):
        self.model = SentenceTransformer(model_name)
        self.tag_descriptions = self.create_tag_descriptions()

    def get_transcript_df(self, filename):
        doc = docx.Document(filename)
        full_text = " ".join(
            [para.text.strip() for para in doc.paragraphs if para.text.strip() != ""]
        )
        full_text = re.sub(r"\s+", " ", full_text).strip()

        # Remove all colons from the full text
        full_text = re.sub(r":", "", full_text)

        transcript = re.split(r"(Interviewer|Interviewee(?: \d+)?)", full_text)
        clean_transcript = []

        speaker, text = None, ""
        for segment in transcript:
            segment = segment.strip()

            # Check if the segment is a speaker label (Interviewer or any Interviewee variant)
            if re.match(r"(Interviewer|Interviewee(?: \d+)?)", segment):
                # If there is a previous speaker and text, add it to the transcript list
                if speaker and text:
                    clean_transcript.append((speaker, text.strip()))
                # Update the speaker to the current segment
                speaker = segment
                text = ""  # Reset text for the new speaker
            else:
                # Append text to the current speaker's text segment
                text += f" {segment}"

        if speaker and text:
            clean_transcript.append((speaker, text.strip()))

        df = pd.DataFrame(clean_transcript, columns=["speaker", "text"])
        df["text"] = df["text"].fillna("")
        df["text_length"] = df["text"].str.len()

        split_rows = []
        for row in df.itertuples(index=False):
            if row.speaker == "Interviewer":
                sentences = re.split(r"([^.?!]*\?+)", row.text)
                sentences = [s.strip() for s in sentences if s.strip()]
                for sentence in sentences:
                    if "?" in sentence:
                        parts = re.split(r"(\?+)", sentence)
                        combined_sentence = "".join(parts)
                        split_rows.append(
                            {"speaker": "Interviewer", "text": combined_sentence}
                        )
                    else:
                        split_rows.append({"speaker": "Interviewer", "text": sentence})
            else:
                split_rows.append({"speaker": row.speaker, "text": row.text})

        return pd.DataFrame(split_rows)

    def create_tag_descriptions(self):
        keys = [
            "Introduction",
            "Background",
            "Leadership and Vision",
            "Curriculum, Instruction and Assessment",
            "Culture and Climate",
            "Targeted Instruction and Support",
            "Closing Arguments",
        ]
        values = [
            ["Introduction"],
            ["Background and School Context"],
            [
                "Focused, Shared Vision and Goals",
                "Distributed Leadership and Sustainability",
                "Culture of Continuous Improvement",
                "Aligned, Consistent Professional Development",
            ],
            [
                "High-Quality, Defined Curriculum",
                "Collaborative Planning",
                "High Expectations, Rigorous Instruction",
                "Teacher Observation and Feedback",
                "Assessment Collection and Collaborative Data Use",
            ],
            [
                "Positive Interpersonal Relationships",
                "Warm and Responsive Environment",
                "Student Voice and Feedback",
                "Family Collaboration",
                "Community Resources and Engagement",
            ],
            [
                "Multitiered Systems of Support",
                "Inclusive and Differentiated Instruction",
                "Enrichment (Elementary)",
                "College and Career Readiness Opportunities (Secondary)",
            ],
            ["Conclusion"],
        ]
        tags_dict = dict(zip(keys, values))

        tag_descriptions = []
        for main_area, tags in tags_dict.items():
            for tag in tags:
                tag_descriptions.append(f"{main_area}: {tag}")
        return tag_descriptions

    def suggest_questions_by_speaker(
        self, df, questions, top_n=1, similarity_threshold=0.6
    ):
        interviewer_texts = df[
            (df["speaker"] == "Interviewer") & (df["text"].str.contains("\?"))
        ].reset_index(drop=True)
        text_embeddings = self.model.encode(interviewer_texts["text"].tolist())
        question_embeddings = self.model.encode(questions["Questions_Text"].tolist())
        text_embeddings = text_embeddings / np.linalg.norm(
            text_embeddings, axis=1, keepdims=True
        )
        question_embeddings = question_embeddings / np.linalg.norm(
            question_embeddings, axis=1, keepdims=True
        )
        similarities = np.dot(text_embeddings, question_embeddings.T)

        for n in range(1, top_n + 1):
            df[f"top_{n}_question"] = None
            df[f"top_{n}_qscore"] = None

        last_matched_question, last_matched_score = None, None
        interviewer_indices = df[
            (df["speaker"] == "Interviewer") & (df["text"].str.contains("\?"))
        ].index

        for idx, similarity_row in enumerate(similarities):
            filtered_indices = np.where(similarity_row >= similarity_threshold)[0]
            filtered_similarities = similarity_row[filtered_indices]
            top_indices = filtered_indices[
                np.argsort(filtered_similarities)[-top_n:][::-1]
            ]
            top_questions = [
                questions.loc[index, "Questions_Text"] for index in top_indices
            ]
            top_scores = [similarity_row[index] for index in top_indices]

            interviewer_idx = interviewer_indices[idx]
            for j, (question, score) in enumerate(
                zip(top_questions, top_scores), start=1
            ):
                df.loc[interviewer_idx, f"top_{j}_question"] = question
                df.loc[interviewer_idx, f"top_{j}_qscore"] = score

            last_matched_question = (
                top_questions[0] if top_questions else last_matched_question
            )
            last_matched_score = top_scores[0] if top_scores else last_matched_score

            next_idx = interviewer_idx + 1
            while next_idx < len(df) and re.match(
                r"Interviewe \d+", df.loc[next_idx, "speaker"]
            ):
                df.loc[next_idx, "top_1_question"] = last_matched_question
                df.loc[next_idx, "top_1_qscore"] = last_matched_score
                next_idx += 1

        questions2 = questions[
            [
                "Questions_Text",
                "Domain",
                "Indicator_Number",
                "Indicator_Description",
                "Aspects_of_Criteria",
            ]
        ]
        df = pd.merge(
            df,
            questions2,
            left_on="top_1_question",
            right_on="Questions_Text",
            how="left",
        )
        return df

    def get_crosswalk_path(self, file_status_filename=None):
        # Define keyword-to-path mappings
        crosswalk_paths = {
            "principal": "transcript_tagging_crosswalks/ILNA_Principal_Focus_Group_Crosswalk.xlsx",
            "teacher": "transcript_tagging_crosswalks/ILNA_Teacher_Focus_Group_Crosswalk.xlsx",
            "student": "transcript_tagging_crosswalks/ILNA_Student_Focus_Group_Crosswalk.xlsx",
            "staff": "transcript_tagging_crosswalks/ILNA_Teacher_Focus_Group_Crosswalk.xlsx",
        }

        # Convert the filename to lowercase
        file_status_filename_type = file_status_filename["audio_file_upload_type"]

        # Check if any keyword is in the filename
        for key, path in crosswalk_paths.items():
            if key in file_status_filename_type:
                return path

        # If no match is found, raise an error with more context
        raise ValueError(
            f"Filename '{file_status_filename}' does not contain a valid type (principal, teacher, student)"
        )

    def fill_interviewee_columns(self, df):
        # Define the columns to fill for Interviewee rows based on the previous Interviewer row
        columns_to_fill = [
            "Questions_Text",
            "Domain",
            "Indicator_Number",
            "Indicator_Description",
            "Aspects_of_Criteria",
        ]

        # Initialize a dictionary to keep track of the last non-empty Interviewer values for each column
        last_filled_values = {col: None for col in columns_to_fill}

        # Iterate over the DataFrame rows
        for idx, row in df.iterrows():
            # If the row is for an Interviewer and has non-empty values in the target columns, update last_filled_values
            if (
                row["speaker"] == "Interviewer"
                and not row[columns_to_fill].isnull().all()
            ):
                for col in columns_to_fill:
                    # Update only if the column is non-empty for the Interviewer row
                    if pd.notnull(row[col]):
                        last_filled_values[col] = row[col]

            # If the row is for an Interviewee, fill in the target columns with the last non-empty Interviewer values
            elif row["speaker"].startswith("Interviewee"):
                for col in columns_to_fill:
                    # Only fill if the column is empty in the Interviewee row
                    if pd.isnull(row[col]):
                        df.at[idx, col] = last_filled_values[col]

        return df

    def run_transcript_tagging(
        self, file_status=None, transcripts_path="word_diarized_transcripts/"
    ):
        filenames = [
            os.path.join(root, file)
            for root, dirs, files in os.walk(transcripts_path)
            for file in files
            if file.endswith(".docx") and "~$" not in file
        ]

        transcripts_dict = {
            filename: self.get_transcript_df(filename) for filename in filenames
        }

        dfs = []
        for filename, _df in transcripts_dict.items():
            # print(filename)
            try:
                root_logger.info(f"Starting transcript tagging process for {filename}")
                df = _df.copy()
                if filename.endswith(".docx"):
                    word_doc_fp = os.path.splitext(os.path.basename(filename))[0]
                    clean_word_doc_fp = word_doc_fp.replace("diarized_", "")
                crosswalk_path = self.get_crosswalk_path(file_status[clean_word_doc_fp])
                questions = pd.read_excel(crosswalk_path)
                questions = (
                    questions.dropna(subset=["Questions_Text"])
                    .drop_duplicates(subset=["Questions_Text"])
                    .reset_index(drop=True)
                )

                df = self.suggest_questions_by_speaker(df, questions)
                df = self.fill_interviewee_columns(df)
                df["filename"] = filename
                dfs.append(df)
                # Log success
                root_logger.info(
                    f"Processed and saved {filename} during transcript tagging"
                )
            except Exception as e:
                root_logger.error(
                    f"An error occurred during transcript tagging processing: {e}"
                )

            try:
                for df in dfs:
                    # Modify the filename to replace 'diarized' with 'tagged_transcript'
                    original_filename = (
                        df["filename"].iloc[0].split("/")[-1].replace(".docx", ".csv")
                    )
                    modified_filename = original_filename.replace(
                        "diarized", "tagged_transcript"
                    )

                    df = df.drop(columns=["top_1_question", "top_1_qscore", "filename"])
                    df.to_csv(f"tagged_transcripts/{modified_filename}", index=False)

                    # Update the file status dictionary
                    without_prefix = modified_filename.removeprefix(
                        "tagged_transcript_"
                    )
                    result = without_prefix.split(".")[0]
                    file_status[result]["tagged"] = True

                    root_logger.info(f"Saved {filename}")
            except Exception as e:
                root_logger.error(
                    f"An error occurred during transcript tagging csv file creation: {e}"
                )

        return file_status


# Usage
# if __name__ == "__main__":
#     tagger = Transcript_Tagging()
#     tagger.run_transcript_tagging()
