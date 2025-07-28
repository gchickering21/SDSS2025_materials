import json
import os

import pandas as pd

INDICATOR_MAP_FP = "meta_data/indicator_number_map.json"


def sort_transcript(fp):
    """
    Takes an input flagged transcript in CSV format and sorts transcript by indicators and questions

    :param fp: File path to CSV file
    :returns: Dictionary indexed by keys, each associated with another dictionary index by questions, each associated with a list of lines (speaker/text dict)
    """
    df = pd.read_csv(fp)
    sorted_transcript = {}
    for index, row in df.iterrows():
        if row["Indicator_Number"] is None or pd.isna(row["Indicator_Number"]):
            continue

        # Initialize key
        key = row["Indicator_Number"]
        if key not in sorted_transcript:
            sorted_transcript[key] = ""

        # Add speaker and text
        sorted_transcript[key] += f"Speaker {row['speaker']}: {row['text']}\n"
    return sorted_transcript


def sort_transcript_questions(fp):
    """
    Takes an input flagged transcript in CSV format and sorts transcript by indicators and questions

    :param fp: File path to CSV file
    :returns: Dictionary indexed by keys, each associated with another dictionary index by questions, each associated with a list of lines (speaker/text dict)
    """
    df = pd.read_csv(fp)
    sorted_transcript = {}
    for index, row in df.iterrows():
        # Initialize key
        key = row["Indicator_Number"]
        if key not in sorted_transcript:
            sorted_transcript[key] = {}

        # Initialize question
        question = row["Questions_Text"]
        if question not in sorted_transcript[key]:
            sorted_transcript[key][question] = []

        # Add speaker and text
        sorted_transcript[key][question].append(
            {"Speaker": row["speaker"], "Text": row["text"]}
        )
    return sorted_transcript


def flagged_transcript_csv(input_fp, output_csv):
    """
    Takes an input flagged transcript in CSV or Excel format and saves it as CSV to output_csv

    :param fp: file path to CSV or Excel file
    """
    # Determine file format and retrieve sorted transcript
    extension = os.path.splitext(input_fp)[-1]
    if extension == ".csv":
        sorted_transcript = sort_transcript_questions(input_fp)

    # Load indicator map
    with open(INDICATOR_MAP_FP, "r") as file:
        map = json.load(file)

    # Create output CSV
    output_list = []
    for key in map:
        row = {
            "Indicator_Number": key,
            "Standard_Name": map[key]["Standard"],
            "Indicator_Name": map[key]["Name"],
        }
        if key in sorted_transcript:
            text = []
            for question in sorted_transcript[key]:
                for line in sorted_transcript[key][question]:
                    text.append(f"{line['Speaker']}: {line['Text']}")
            row["Transcript"] = "\n".join(text)
        output_list.append(row)

    # Save output
    pd.DataFrame(output_list).set_index("Indicator_Number", inplace=False).to_csv(
        output_csv
    )


# def main():
#     flagged_transcript_csv(
#         input_fp="tagged_transcripts/diarized_2024-ilna-cps299-brightonpark-principalinterview-md.csv",
#         output_csv="test.csv",
#     )


# if __name__ == "__main__":
#     main()

