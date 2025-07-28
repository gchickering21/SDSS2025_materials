import io
import os
import smtplib
from datetime import datetime
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from dotenv import load_dotenv

from .sharepoint_automation import print_green, print_red


class EmailSender:
    def __init__(self, report_log_df):
        # Load environment variables
        load_dotenv()

        # Pre-processing
        self.current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M")

        # Email configuration
        self.from_address = os.getenv("FROM")
        self.mailhub = os.getenv("MAILHUB")
        self.port = os.getenv("PORT")
        self.auth_user = os.getenv("AUTHUSER")
        self.auth_pass = os.getenv("AUTHPASS")
        self.report_log_df = report_log_df

        # If PORT is not defined, immediately casting to int without a check throws an error
        if self.port:
            self.port = int(self.port)

        # Define recipient groups (replace with actual emails)
        self.data_science_team = ["test.org"]
        self.project_team = ["test.org"]

        # Check for missing environment variables
        variables = [
            self.from_address,
            self.mailhub,
            self.port,
            self.auth_user,
            self.auth_pass,
        ]
        missing_vars = [value is None for value in variables]
        if any(missing_vars):
            variable_names = ["FROM", "MAILHUB", "PORT", "AUTHUSER", "AUTHPASS"]
            missing_var_names = [
                name for name, missing in zip(variable_names, missing_vars) if missing
            ]
            # print_red(f"Error: Missing required environment variables: {', '.join(missing_var_names)}")
            raise KeyError(
                f"Error: Missing required environment variables: {', '.join(missing_var_names)}"
            )

    def create_body(self, group):
        """Create the email body based on the recipient group."""
        header = "Report Creation Overview"
        custom_message = (
            "This contains the statuses for the newly created reports.<br><br>"
            "Please check the 'status' column for any errors and alert DS Team if there are any.<br><br>"
        )

        # Basic HTML body structure
        body = f"<h3>{header}</h3><p>{custom_message}</p><br>"

        # Attach full CSV file for data_science_team and add subset to email body
        if group == "data_science_team":
            # Convert the DataFrame to CSV in memory
            csv_buffer = io.StringIO()
            self.report_log_df.to_csv(csv_buffer, index=False)
            csv_buffer.seek(0)  # Move to the start of the buffer

            # Attach the CSV file
            filename = f"report_log_{self.current_datetime}.csv"
            attachment = MIMEApplication(csv_buffer.getvalue())
            attachment.add_header(
                "Content-Disposition", "attachment", filename=filename
            )
            self.msg.attach(attachment)

            # Include DataFrame subset in email body
            subset_df = self.report_log_df[
                ["rcdts", "key", "school_name", "district_name", "status_label"]
            ]
            body += "<h4>Data Science Report Log:</h4>"
            body += subset_df.to_html(index=False)  # Full DataFrame

        # For project_team, add subset to email body only
        elif group == "project_team":
            subset_df = self.report_log_df[
                ["rcdts", "key", "school_name", "district_name", "status_label"]
            ]
            body += "<h4>Project Team Report Log:</h4><p>If any errors, see the full report_log attachment.</p>"
            body += subset_df.to_html(index=False)  # Subset DataFrame

        # Attach the email body as HTML after fully constructing it
        self.msg.attach(MIMEText(body, "html"))

    def send_email(self, recipients):
        """Send email to the specified recipients."""
        # print(self.msg.as_string())
        try:
            self.msg["From"] = self.from_address
            self.msg["To"] = ", ".join(recipients)

            # Connect to SMTP server and send email
            with smtplib.SMTP(self.mailhub, self.port) as server:
                server.starttls()
                print(self.auth_user)
                print(self.auth_pass)
                server.login(self.auth_user, self.auth_pass)
                server.sendmail(self.from_address, recipients, self.msg.as_string())
                print_green(f"Email sent successfully to {', '.join(recipients)}!")
        except Exception as e:
            print_red(
                f"Error sending email to {', '.join(recipients)}: {e}",
            )
            raise e

    def send_to_group(self):
        """Send tailored emails to both groups."""
        # Send email to data science team with the full DataFrame as an attachment
        self.msg = MIMEMultipart()  # Reset message for each send
        self.msg["Subject"] = (
            f"ILNA Report Running: Data Science Team Overview {self.current_datetime}"
        )
        self.create_body(group="data_science_team")
        self.send_email(recipients=self.data_science_team)

        # Send email to project team with the subset DataFrame in the body
        self.msg = MIMEMultipart()  # Reset message for each send
        self.msg["Subject"] = (
            f"ILNA Report Running: Project Team Overview {self.current_datetime}"
        )
        self.create_body(group="project_team")
        self.send_email(recipients=self.project_team)


# Usage Example
# email_sender = EmailSender(report_log_df=error_df_py)
# email_sender.send_to_group()
