import json
import os
import pickle
import re
import time

import pandas as pd
from openai import RateLimitError
from tqdm import tqdm

import scripts.lib as lib
import scripts.sort_transcript as sort_transcript
from scripts.config import Config
from scripts.logging_config import root_logger
from scripts.openai_usage import log_openai_usage


def construct_messages(
    prompt_info, transcript_type, transcript, indicator, retry=False
):
    """
    Create messages based on provided data

    :param client: gpt client
    :param prompt_info: prompt info json object
    :param transcript_type: type of transcript (principals, teachers, students)
    :param transcript: section of transcript provided
    :param indicator: indicator being analyzed
    """
    system_context = prompt_info["system_context"]
    description = prompt_info["transcript_descriptions"][transcript_type]
    prompt = "\n".join(list(prompt_info["prompts"].values()))
    messages = [
        {
            "role": "system",
            "content": system_context,
        },
        {"role": "user", "content": description + "\n" + transcript},
        {
            "role": "user",
            "content": "I will ask questions about the transcript relating to the following indicator: "
            + indicator["indicator_name"]
            + ": "
            + indicator["description"]
            + "\n"
            + prompt,
        },
    ]
    if retry:
        # Add a retry-specific message
        retry_message = {
            "role": "user",
            "content": "This is a retry attempt. Even though results were found previously for this indicator, "
            "please reanalyze and ensure no additional insights are missed. Provide a thorough review of "
            "the transcript and elaborate on your findings.",
        }
        messages.append(retry_message)
    return messages


def get_response(client, messages, attempt=1, logfile_fp="./logs/openai_api_log.csv"):
    """
    Take a message history and process it using the client

    :param client: gpt client
    :param messages: message history to process
    :param attempt:
    :param logfile_fp: path to logfile for keeping track of token usage
    """
    try:
        response = client.chat.completions.create(
            model="gpt-4o", temperature=0, top_p=0.95, max_tokens=800, messages=messages
        )
        messages.append(
            {
                "role": response.choices[0].message.role,
                "content": response.choices[0].message.content,
            }
        )
        log_openai_usage(response, logfile_fp)
        return response.choices[0].message.content
    except RateLimitError:
        if attempt >= 2:
            raise
        root_logger.warning("Rate limit exceeded. Waiting 1 minute...")
        time.sleep(60)
        return get_response(client, messages, attempt=attempt + 1)


def parse_section(section, prompt_type):
    """
    Parse section of a transcript

    :param section: section of transcript
    :prompt_type: type of prompt (findings, agreements, summary)
    """
    if section in [
        "There were no key findings identified.",
        "There were no agreements or disagreements identified.",
        "There is nothing to summarize.",
        "No Agreements were identified for this indicator.",
        "No Disagreements were identified for this indicator.",
        "No finding was provided.",
        "There was no quote found for this finding.",
    ]:
        return []

    if prompt_type != "summary":
        section = re.findall(r"\d\. (.*)", section)
    else:
        section = ["SUMMARY: " + section]
    return section


def renumber_lines(lines):
    """
    Renumber a list of lines sequentially starting from 1.

    :param lines: List of strings with numbered lines
    :return: List of strings with updated numbering
    """
    return [f"{i + 1}. {line.split('. ', 1)[1]}" for i, line in enumerate(lines)]


def split_agreements_and_disagreements(agreements_content):
    """
    Split the agreements and disagreements from the provided content.

    :param agreements_content: Text containing agreements and disagreements
    :return: A tuple (agreements, disagreements) where each is a list of strings
    """
    agreements = []
    disagreements = []
    for line in agreements_content.split("\n"):
        line = line.strip()
        if "DISAGREEMENT" in line.upper():
            disagreements.append(line)
        elif "AGREEMENT" in line.upper():
            agreements.append(line)

    agreements = (
        renumber_lines(agreements)
        if agreements
        else ["No Agreements were identified for this indicator."]
    )
    disagreements = (
        renumber_lines(disagreements)
        if disagreements
        else ["No Disagreements were identified for this indicator."]
    )

    # # Debugging: Print the results
    # print("Agreements:", agreements)
    # print("Disagreements:", disagreements)
    return agreements, disagreements


def split_findings_and_quotes(findings_content):
    """
    Split the findings content into separate numbered arrays for findings and quotes.

    :param findings_content: Text containing findings in Markdown table format
    :return: Two lists: one for numbered findings and one for numbered quotes
    """
    findings_list = []
    quotes_list = []
    lines = findings_content.split("\n")

    # Skip the header and separator lines
    for index, line in enumerate(
        lines[2:], start=1
    ):  # Assumes the first two lines are header and separator
        if "|" not in line:
            continue
        parts = line.split("|")[
            1:-1
        ]  # Extract the content between the table's `|` separators
        finding = parts[0].strip() if len(parts) > 0 else None
        quote = parts[1].strip() if len(parts) > 1 else None

        # Add numbered finding
        if finding:
            findings_list.append(f"{index}. FINDING: {finding}")
        else:
            findings_list.append(f"{index}. No finding was provided.")

        # Add numbered quote or a default message
        if quote:
            quotes_list.append(f"{index}. QUOTE: {quote}")
        else:
            quotes_list.append(f"{index}. There was no quote found for this finding.")

    # print("Findings:", findings_list)
    # print("Quotes:", quotes_list)
    return findings_list, quotes_list


def transform_to_rows(
    indicator,
    indicator_info,
    findings_list,
    quotes_list,
    agreements,
    disagreements,
    summary_content,
):
    """
    Transform parsed content into a row-per-item structure, including numbering for items.

    :param indicator: Indicator number being analyzed.
    :param indicator_info: Dictionary containing standard name and indicator name.
    :param findings_list: List of findings.
    :param quotes_list: List of quotes.
    :param agreements: List of agreements.
    :param disagreements: List of disagreements.
    :param summary_content: Summary content.
    :return: List of rows formatted as dictionaries.
    """
    data = []

    # Add summary as a single row without a number
    data.append(
        {
            "Indicator Number": indicator,
            "Standard Name": indicator_info["standard_name"],
            "Indicator Name": indicator_info["indicator_name"],
            "Category": "Summary",
            "Content": summary_content,
        }
    )

    # Process findings
    for i, finding in enumerate(findings_list, start=1):
        data.append(
            {
                "Indicator Number": indicator,
                "Standard Name": indicator_info["standard_name"],
                "Indicator Name": indicator_info["indicator_name"],
                "Category": "Finding",
                "Content": finding,
            }
        )

    # Process quotes
    for i, quote in enumerate(quotes_list, start=1):
        data.append(
            {
                "Indicator Number": indicator,
                "Standard Name": indicator_info["standard_name"],
                "Indicator Name": indicator_info["indicator_name"],
                "Category": "Quote",
                "Content": quote,
            }
        )

    # Process agreements
    for i, agreement in enumerate(agreements, start=1):
        data.append(
            {
                "Indicator Number": indicator,
                "Standard Name": indicator_info["standard_name"],
                "Indicator Name": indicator_info["indicator_name"],
                "Category": "Agreement",
                "Content": agreement,
            }
        )

    # Process disagreements
    for i, disagreement in enumerate(disagreements, start=1):
        data.append(
            {
                "Indicator Number": indicator,
                "Standard Name": indicator_info["standard_name"],
                "Indicator Name": indicator_info["indicator_name"],
                "Category": "Disagreement",
                "Content": disagreement,
            }
        )
    return data


def parse_content(content, indicator, indicator_info):
    """
    Parse GPT output

    :param content: response from gpt call
    :param indicator: indicator being analyzed
    :param indicator_info: data about the indicator from prompt_info
    """
    try:
        content = content.replace("**", "").replace("’", "'")
        findings_title = re.search(r".*FINDINGS.*", content)
        agreements_title = re.search(r".*AGREEMENTS AND DISAGREEMENTS.*", content)
        summary_title = re.search(r".*SUMMARY.*", content)

        findings_start = findings_title.span()[1]
        findings_end = agreements_title.span()[0]
        findings_content = content[findings_start:findings_end].strip()

        # Process Findings and Quotes
        findings, quotes = split_findings_and_quotes(findings_content)

        agreements_start = agreements_title.span()[1]
        agreements_end = summary_title.span()[0]
        agreements_content = content[agreements_start:agreements_end].strip()

        # Split Agreements and Disagreements using the new function
        # Debugging: Check the content before splitting
        agreements, disagreements = split_agreements_and_disagreements(
            agreements_content
        )

        # Find Summary
        summary_content = content[summary_title.span()[1] :].strip()
        summary_with_label = f"SUMMARY: {summary_content}"

        ## Transform into a list of dictionaries
        result = transform_to_rows(
            indicator=indicator,
            indicator_info=indicator_info,
            findings_list=findings,
            quotes_list=quotes,
            agreements=agreements,
            disagreements=disagreements,
            summary_content=summary_with_label,
        )
        return result
    except Exception:
        return []


def analyze_transcript_indicator(
    gpt_client, indicator, transcript, transcript_type, retry=False
):
    """
    Process getting response for one indicator and the corresponding transcript section

    :param indicator: indicator being analyzed
    :param transcript: section of transcript provided
    :param transcript_type: type of transcript (principals, teachers, students)
    :param azure_config: config object
    """
    with open("meta_data/prompt_info.json") as f:
        prompt_info = json.load(f)

    messages = construct_messages(
        prompt_info,
        transcript_type,
        transcript,
        prompt_info["indicators"][indicator],
        retry=retry,
    )
    content = get_response(gpt_client, messages)
    # print("got content?")
    # print(content)
    result = parse_content(content, indicator, prompt_info["indicators"][indicator])
    return result


class ResultStore:
    """
    This class handles list storage by writing output to pickle files.
    Users can store a list in self.result and update it with the extend() method to make sure output gets saved.
    If the program quits, then upon restarting the program we can reload the list from the associated pickle file
    """

    def __init__(self, transcript_fp):
        filename = os.path.split(transcript_fp)[-1]
        self.pickle_fp = f"test_output/{filename}.pkl"
        if os.path.exists(self.pickle_fp):
            with open(self.pickle_fp, "rb") as f:
                self.result = pickle.load(f)
            self.processed_indicators = {r["Indicator Name"] for r in self.result}
        else:
            self.result = []
            self.processed_indicators = set()

    def extend(self, result):
        """
        Users should call extend to add results to the self.result list.
        This will update the list, save the updated pickle file, and update our set of processed_indicators.

        :param result: input results to get added to self.result
        """
        self.result.extend(result)
        with open(self.pickle_fp, "wb") as f:
            pickle.dump(self.result, f)
        self.processed_indicators.update({r["Indicator Name"] for r in result})


def analyze_transcript(gpt_client, transcript_fp, transcript_type, filename):
    """
    Loop through indicators, call analyzer, and store results.
    Resumes from saved progress if a failure occurs.

    :param transcript_fp: full path to the transcript being analyzed
    :param transcript_type: type of transcript (principals, teachers, students)
    """
    with open("meta_data/prompt_info.json") as f:
        prompt_info = json.load(f)

    rs = ResultStore(transcript_fp)
    sorted_transcript = sort_transcript.sort_transcript(transcript_fp)
    for indicator in tqdm(sorted_transcript, desc="Looping through Indicators"):
        try:
            if indicator in rs.processed_indicators:
                continue
            if indicator == "Introduction":
                root_logger.warning("Skipping intro indicator")
                continue
            # Retry logic for analyze_transcript_indicator
            for attempt in range(1, 11):  # Try up to 3 times
                is_retry = attempt > 4  # Set retry flag
                result = analyze_transcript_indicator(
                    gpt_client,
                    indicator,
                    sorted_transcript[indicator],
                    transcript_type,
                    retry=is_retry,
                )
                if result:
                    time.sleep(2)  # If result is not empty, break the retry loop
                    break
                root_logger.warning(
                    f"Retry {attempt} for indicator {indicator} for {filename} returned no results."
                )
                time.sleep(5)
            else:
                no_result_entry = {
                    "Indicator Number": indicator,
                    "Standard Name": prompt_info["indicators"][indicator][
                        "standard_name"
                    ],
                    "Indicator Name": prompt_info["indicators"][indicator][
                        "indicator_name"
                    ],
                    "Category": "Summary",
                    "Content": "No AI Findings were found at this time",
                }
                rs.extend([no_result_entry])  # Add the entry to the result store
                continue
            rs.extend(result)
        except Exception as e:
            root_logger.error(
                f"An error occurred: {e}. Progress saved to {rs.pickle_fp}."
            )
    return rs.result


def get_transcript_type_from_filestatus(file_status_filename=None):
    """
    Determine transcript type from filename.
    :param filename: Name of the file
    :return: transcript_type (e.g., 'principals', 'teachers', or 'students')
    """
    keywords = {
        "principal": "principals",
        "teacher": "teachers",
        "student": "students",
        "staff": "teachers",
    }

    file_status_filename_type = file_status_filename["audio_file_upload_type"]
    for key, transcript_type in keywords.items():
        if key in file_status_filename_type:
            return transcript_type

    raise ValueError(
        f"Unknown transcript type in filename: {file_status_filename_type}"
    )


def category_sort_key(category):
    """
    Custom sort key for the 'Category' column.
    """
    category_order = {
        "Summary": 1,
        "Findings": 2,
        "Quotes": 3,
        "Agreements": 4,
        "Disagreements": 5,
    }
    return category_order.get(
        category, float("inf")
    )  # Default to inf for unexpected categories


def produce_ai_findings(
    gpt_client,
    file_status=None,
    folder_path="tagged_transcripts",
    output_folder="ai_findings",
):
    """
    Process all transcript files in the specified folder, save each output in the desired format.
    :param gpt_client: GPT client to process transcripts
    :param folder_path: Path to the folder containing transcript files
    :param output_folder: Folder to save processed output
    """

    for filename in os.listdir(folder_path):
        if filename.endswith(".csv"):
            transcript_fp = os.path.join(folder_path, filename)
            try:
                if filename.endswith(".csv"):
                    tagged_transcript_fp = os.path.splitext(os.path.basename(filename))[
                        0
                    ]
                    clean_tagged_transcript_fp = tagged_transcript_fp.replace(
                        "tagged_transcript_", ""
                    )
                # Determine transcript type from filename
                transcript_type = get_transcript_type_from_filestatus(
                    file_status[clean_tagged_transcript_fp]
                )
                # print(f"AI type: {transcript_type}")
                # Analyze the transcript
                result = analyze_transcript(gpt_client, transcript_fp, transcript_type, filename)
                # Save the results to a DataFrame and output CSV
                df = pd.DataFrame(result)

                # Sort using a custom key that splits the number and letter in-place for sorting
                category_custom_order = [
                    "Summary",
                    "Finding",
                    "Quote",
                    "Agreement",
                    "Disagreement",
                ]
                # Convert the 'Category' column to a categorical type with the custom order
                df["Category"] = pd.Categorical(
                    df["Category"], categories=category_custom_order, ordered=True
                )

                df = df.sort_values(by=["Indicator Number", "Category"])

                output_fp = os.path.join(
                    output_folder,
                    f"{filename.replace('tagged_transcript_', 'ai_findings_').rsplit('.', 1)[0]}.csv",
                )

                df.to_csv(output_fp, index=False)

                # Update the file status dictionary
                without_prefix = filename.removeprefix("tagged_transcript_")
                result = without_prefix.split(".")[0]
                file_status[result]["ai_findings_produced"] = True

                root_logger.info(f"Processed and saved: {output_fp}")

            except Exception as e:
                root_logger.warning(
                    f"An error occurred while processing {filename}: {e}"
                )

    return file_status


# def main():
#     # Get GPT Client
#     config = Config("resources/config.ini")
#     azure_config = config.get_azure_config()
#     gpt_client = lib.get_gpt_client(azure_config)

#     # Analyze transcript
#     transcript_fp = (
#         "tagged_transcripts/2024ilna-auroraeast131-rollinselem-teacherfocusgroup-ak.csv"
#     )
#     transcript_type = "teachers"
#     result = analyze_transcript(gpt_client, transcript_fp, transcript_type)
#     df = pd.DataFrame(result)
#     df.to_csv("test_output/rollinselem_teacher.csv", index=False)


# if __name__ == "__main__":
#     main()
