# logging_config.py
import logging
from datetime import datetime

from colorama import Fore, Style, init

# Initialize colorama (optional if no console colors are needed)
init(autoreset=True)

# Configure log file path
DATE = datetime.now().strftime("%Y-%m-%d_%H-%M")
log_filename = f"daily_logs/{DATE}.log"

# File logging setup: logs go exclusively to the specified file
logging.basicConfig(
    filename=log_filename,
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)

# Set specific log levels to reduce verbosity from external libraries
logging.getLogger("azure.core.pipeline.policies.http_logging_policy").setLevel(
    logging.WARNING
)
logging.getLogger("azure.identity").setLevel(logging.WARNING)


# Define and apply filter to restrict to specific messages if needed
class RootFilter(logging.Filter):
    def filter(self, record):
        return record.name == "root" and record.levelname in [
            "DEBUG",
            "INFO",
            "WARNING",
            "ERROR",
            "CRITICAL",
        ]


root_logger = logging.getLogger()
root_filter = RootFilter()
root_logger.addFilter(root_filter)


# (Optional) Custom formatter for log file entries
class CustomColoredFormatter(logging.Formatter):
    def format(self, record):
        # Convert record.msg to a string before checking for "Completed"
        if "Completed" in str(record.msg):
            record.msg = f"{Fore.GREEN}{record.msg}{Style.RESET_ALL}"
        return super().format(record)


# Apply the custom formatter to root logger's file handler (if needed)
for handler in root_logger.handlers:
    handler.setFormatter(
        CustomColoredFormatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    )
