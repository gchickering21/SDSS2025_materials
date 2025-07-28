import csv
import datetime
import os


def check_logfile(logfile_fp="./openai_api_log.csv"):
    if not os.path.exists(logfile_fp):
        dirname = os.path.dirname(logfile_fp)
        os.makedirs(dirname, exist_ok=True)
        with open(logfile_fp, "w", newline="") as csvfile:
            csvwriter = csv.writer(csvfile)
            csvwriter.writerow(
                [
                    "Date",
                    "ID",
                    "Model",
                    "Object",
                    "System Fingerprint",
                    "Completion Tokens",
                    "Prompt Tokens",
                    "Total Tokens",
                ]
            )


def log_openai_usage(response, logfile_fp="./openai_api_log.csv"):
    check_logfile(logfile_fp)
    with open(logfile_fp, "a", newline="") as csvfile:
        csvwriter = csv.writer(csvfile)
        row = [
            datetime.datetime.fromtimestamp(response.created),
            response.id,
            response.model,
            response.object,
            response.system_fingerprint,
            response.usage.completion_tokens,
            response.usage.prompt_tokens,
            response.usage.total_tokens,
        ]
        csvwriter.writerow(row)
