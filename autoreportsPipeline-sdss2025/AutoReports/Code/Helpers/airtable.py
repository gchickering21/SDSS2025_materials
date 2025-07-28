import os
import pandas as pd
from dotenv import load_dotenv
from pyairtable import Api

class AirtableClient:
    def __init__(self, base_id, dotenv_path=".env", ca_bundle_path="/etc/ssl/certs/ca-certificates.crt", local_run = False):
        """
        Initializes the AirtableClient with a base ID and optional CA bundle path.

        Parameters:
        base_id (str): The ID of the Airtable base to interact with.
        dotenv_path (str, optional): Path to the .env file containing the AIR_API_TOKEN.
        ca_bundle_path (str, optional): Path to the custom CA bundle for SSL verification.
        """
        # Load environment variables
        load_dotenv(dotenv_path=dotenv_path)

        # Set the CA bundle path for the requests library
        if local_run == False:
            os.environ["REQUESTS_CA_BUNDLE"] = ca_bundle_path

        # Initialize the API
        self.api = Api(os.getenv("AIR_API_TOKEN"))
        self.base_id = base_id

    def get_table_data(self, table_id, field_names_or_ids=None, view=None):
        """
        Fetches data from a specified Airtable table and returns it as a list of dictionaries.

        Parameters:
        table_id (str): The ID of the table to fetch data from.
        field_names_or_ids (list, optional): List of field names or field IDs to include in the output.
        view (str, optional): The name or ID of a view to limit which records are returned.

        Returns:
        list of dict: List of records as dictionaries.
        """
        table = self.api.table(self.base_id, table_id)

        # define keyword arguments for the `all()` method
        options = {}
        if field_names_or_ids is not None:
            options["fields"] = field_names_or_ids
        if view is not None:
            options["view"] = view

        # Fetch records using the specified fields and view if provided
        records = table.all(**options)

        # normalize the records data to a df, then convert to a list of dictionaries
        df = pd.json_normalize(pd.DataFrame(records)["fields"])
        return df.to_dict(orient="records")

    def update_v2_status(self, table_id, status_updates_df):
        """
        Updates the V2 field in Airtable records based on the provided status_updates_df DataFrame.

        Parameters:
        table_id (str): The ID of the table to update records in.
        status_updates_df (DataFrame): DataFrame with columns 'rcdts', 'errors', and 'status_label'.
                                       'rcdts' values are used to identify records, 'errors' to determine the status ('ERROR' or 'DONE'), and 'status_label' to get the error type.
        """
        table = self.api.table(self.base_id, table_id)
        records = table.all(fields=["RCDTS", "V2"])
        # Get list of currently running reports
        # print_green([record['fields'] for record in records])
        running_reports = [
            record["fields"]["RCDTS"]
            for record in records
            if record["fields"].get("V2") == "GENERATING REPORT"
        ]
        # Add missing reports to the status df (occurs if manual interrupt or pipeline errors occur)
        # print(status_updates_df)
        if len(status_updates_df["rcdts"]) < len(running_reports):
            if "MANUAL_INTERRUPT" in status_updates_df["status_label"].values:
                err_msg = status_updates_df[
                    status_updates_df["status_label"] == "MANUAL_INTERRUPT"
                ].get("pipeline_log")[0]
                err_label = "MANUAL_INTERRUPT"
            elif "PIPELINE_ERR" in status_updates_df["status_label"].values:
                err_msg = status_updates_df[
                    status_updates_df["status_label"] == "PIPELINE_ERR"
                ].get("pipeline_log")[0]
                err_label = "PIPELINE_ERR"
            else:  # This is only needed during testing since our test schools are not currently in Airtable, which breaks things
                err_msg = "DONE"
                err_label = "DONE"
            for report in running_reports:
                if (
                    report not in status_updates_df["rcdts"].values
                    and not err_label == "DONE"
                ):
                    status_updates_df = pd.concat(
                        [
                            status_updates_df,
                            pd.DataFrame(
                                {
                                    "rcdts": [report],
                                    "key": [""],
                                    "school_name": [""],
                                    "district_name": [""],
                                    "data_prep_log": [""],
                                    "data_backend_log": [""],
                                    "file_gen_log": [""],
                                    "report_gen_log": [""],
                                    "pipeline_log": [err_msg],
                                    "combined_log": [err_msg],
                                    "combined_error_log": [err_msg],
                                    "combined_warning_log": [""],
                                    "errors": [True],
                                    "warnings": [False],
                                    "status_label": [err_label],
                                }
                            ),
                        ],
                        ignore_index=True,
                    )

        # Convert the df to ERROR or DONE values and turn to a dict for easier processing
        # status_updates_df['status'] = status_updates_df['errors'].apply(lambda x: 'ERROR' if x else 'DONE') ###Need to update to support pipeline errors (error df may not contain all schools if error occurs before report generation)
        status_updates_dict = dict(
            zip(status_updates_df["rcdts"], status_updates_df["status_label"])
        )
        # print(status_updates_dict)
        # print([record['fields'].get('RCDTS') for record in records])
        updates = [
            {
                "id": record["id"],
                "fields": {"V2": status_updates_dict[record["fields"]["RCDTS"]]},
            }
            for record in records
            if record["fields"].get("RCDTS") in status_updates_dict
        ]

        if updates:
            table.batch_update(updates)
        else:
            print("\033[1;31mNo matching records or errors found for update.\033[0m")

    def get_table_field_names(self, table_id):
        table = self.api.table(self.base_id, table_id)
        records = table.all(max_records=1)

        if records:
            field_names = list(records[0]["fields"].keys())
            return field_names
        else:
            return []
