import os
import subprocess
import sys

from AutoReports.Code.Helpers.airtable import AirtableClient
from AutoReports.Code.Helpers.install_missing_packages import install_missing_packages
from AutoReports.Code.Helpers.send_ses_email import EmailSender
from AutoReports.Code.Helpers.sharepoint_automation import (
    SharepointAuthentication,
    print_green,
    print_red,
    print_yellow,
)

# packages = ['asyncio', 'platform', 're', 'ssl', 'argparse', 'pandas', 'importlib', 'subprocess', 'sys', 'os']
try:
    import asyncio
except ImportError:
    install_missing_packages(["asyncio"], load=True)
try:
    import platform
except ImportError:
    install_missing_packages(["platform"], load=True)
try:
    import re
except ImportError:
    install_missing_packages(["re"], load=True)
try:
    import ssl
except ImportError:
    install_missing_packages(["ssl"], load=True)
try:
    import argparse
except ImportError:
    install_missing_packages(["argparse"], load=True)
try:
    import pandas as pd
except ImportError:
    install_missing_packages(["pandas"], load=False)
    import pandas as pd


def get_parameters():
    """
    Parses command-line arguments and returns the values for setup, container_name, image_name, parallel, and verbose.

    - setup: Boolean to run in setup mode (defaults to False).
    - container_name: Name of the Docker container (defaults to 'ilna_autoreports').
    - image_name: Name of the Docker image (defaults to 'autoreports:ILNA').
    - parallel: Boolean to determine if 'report_shell_parallel' should be run (defaults to False).
    - verbose: Boolean to print more information (defaults to True).
    - ec2: Boolean to run on an EC2 instance (defaults to False).
    """
    parser = argparse.ArgumentParser(
        description="Run script with optional Docker and setup parameters."
    )

    # Define arguments
    parser.add_argument(
        "--setup", action="store_true", help="Run in setup mode (default: False)"
    )
    parser.add_argument(
        "--container_name",
        default="ilna_autoreports",
        help="Docker container name (default: 'ilna_autoreports')",
    )
    parser.add_argument(
        "--image_name",
        default="autoreports:ILNA",
        help="Docker image name (default: 'autoreports:ILNA')",
    )
    parser.add_argument(
        "--parallel", action="store_true", help="Run in parallel mode (default: False)"
    )
    parser.add_argument(
        "--verbose", default=True, help="Run with verbose output (default: True)"
    )
    parser.add_argument(
        "--ec2", action="store_true", help="Run on an EC2 instance (default: False)"
    )

    # Parse the arguments
    args = parser.parse_args()
    # Return parsed arguments
    return (
        args.setup,
        args.container_name,
        args.image_name,
        args.parallel,
        args.verbose,
        args.ec2,
    )


def add_err_to_log(e, label):
    error_row = pd.DataFrame(
        {
            "rcdts": [label],
            "key": [label],
            "school_name": [label],
            "district_name": [label],
            "data_prep_log": [""],
            "data_backend_log": [""],
            "file_gen_log": [""],
            "report_gen_log": [""],
            "pipeline_log": [
                f"**ERROR: Error occured outside of individual report iterations:\n\n{e}"
            ],
            "combined_log": [
                f"**ERROR: Error occured outside of individual report iterations:\n\n{e}"
            ],
            "combined_error_log": [
                f"**ERROR: Error occured outside of individual report iterations:\n\n{e}"
            ],
            "combined_warning_log": [""],
            "errors": [True],
            "warnings": [False],
            "status_label": [label],
        }
    )
    error_row.to_csv(
        "AutoReports/batch_log.csv",
        mode="a",
        index=False,
        header=(not os.path.exists("AutoReports/batch_log.csv")),
    )


# Check Azure CLI connection, and prompt a login if no connection is detected
def azure_login():
    result = subprocess.run(
        "az ad signed-in-user show",
        shell=True,
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
    )
    # Return code 1 indicates that no connection is detected (the command failed)
    if result.returncode == 1:
        print_yellow("Logging in to Azure CLI...")
        subprocess.run("az login", shell=True, check=True)
        print_green("Successfully connected to Azure CLI.")
    else:
        print_green("Azure CLI connection detected.")


def cleanup_container(container_name, message_version=1):
    """
    Stops and removes the Docker container with the given name.

    - container_name: Name of the Docker container to stop and remove.
    - message_type: Whether to print a generic "stopping container" message (1) or a the message to display when checking the leftover container from a previous run (2).
    """
    # Check if the container exists
    curr_containers = subprocess.run(
        "docker ps -a", shell=True, check=True, stdout=subprocess.PIPE
    )
    if bool(re.search(f"\\W{container_name}\n", curr_containers.stdout.decode())):
        if message_version == 1:
            print_yellow(f"Removing docker container '{container_name}'...")
        else:
            print_yellow(
                f"Docker container '{container_name}' already exists. Removing it..."
            )
        cleanup_command_1 = f"docker stop {container_name}"
        cleanup_command_2 = f"docker rm -f {container_name}"
        subprocess.run(
            cleanup_command_1, shell=True, check=True, stdout=subprocess.DEVNULL
        )
        subprocess.run(
            cleanup_command_2, shell=True, check=True, stdout=subprocess.DEVNULL
        )
        # print_green("Done!")


async def run_main_and_docker(
    operating_system=None,
    report_creation_type=None,
    container_name=None,
    image_name=None,
    verbose=None,
    ec2=None,
):
    # Create an instance of the SharepointAuthentication class
    auth_manager = SharepointAuthentication()
    if ec2:
        auth_manager.initialize_sharepoint_ec2()
    else:
        auth_manager.initialize_sharepoint()

    await auth_manager.authenticate_and_clear()
    print_green("Output Folder Has Been Cleared")

    # Remove the old container if present
    cleanup_container(container_name, message_version=2)
    if operating_system == "windows":
        docker_creation_command = (
            f"docker run -d -t --name {container_name} "
            f'-v "%cd%"\\AutoReports:/AutoReports/ {image_name}'
        )
    elif operating_system == "mac":
        docker_creation_command = (
            f"docker run -d -t --platform linux/amd64 --name {container_name} "
            f'-v "$(pwd)/AutoReports:/AutoReports/" {image_name} "$@"'
        )
    else:
        # print_red("\nError: Operating system not recognized. Only Windows and Mac are supported.")
        raise RuntimeError(
            "Operating system not recognized. Only Windows and Mac are supported."
        )

    result = subprocess.run(
        docker_creation_command, shell=True, check=True, stdout=subprocess.DEVNULL
    )
    if result.returncode != 0:
        # print_red("\nError starting the Docker container.")
        raise subprocess.CalledProcessError("Unable to start the Docker container.")

    print_green(f"Docker container '{container_name}' started successfully.")

    await asyncio.sleep(3)

    print_yellow("\nRunning report script inside Docker container:\n")
    if report_creation_type == "report_shell":
        second_command = f'docker exec {container_name} bash -c "cd /AutoReports && Rscript report_shell.R"'
        result = subprocess.run(
            second_command, shell=True, check=True, stderr=subprocess.PIPE, text=True
        )
        # if result.returncode != 0:
        #     #print_red("\nError executing the report script inside the Docker container.")
        #     raise subprocess.CalledProcessError("Unable to execute the report script inside the Docker container.")

        print_green("Report script successfully run inside the Docker container.")

    elif report_creation_type == "report_shell_parallel":
        if ec2:
            second_command = f'docker exec {container_name} bash -c "cd /AutoReports && Rscript report_shell_parallel.R"'
            result = subprocess.run(second_command, shell=True, check=True)
            if result.returncode != 0:
                # print_red("\nError executing the report script inside the Docker container.")
                raise subprocess.CalledProcessError(
                    "Unable to execute the report script inside the Docker container."
                )

            print_green("Report script successfully run inside the Docker container.")

        else:
            second_command = f'docker exec {container_name} bash -c "cd /AutoReports && unbuffer Rscript report_shell_parallel.R"'
            result = subprocess.run(
                second_command,
                shell=True,
                check=True,
                stderr=subprocess.PIPE,
                text=True,
            )
            # if result.returncode != 0:
            #     print_red(f"\nError executing the report script inside the Docker container: {result.stderr}")
            #     raise subprocess.CalledProcessError("Unable to execute the report script inside the Docker container.")

            print_green("Report script successfully run inside the Docker container.")

    else:
        # print_red(f'\nReport creation type "{report_creation_type}" not recognized.')
        raise RuntimeError(
            f'Report creation type "{report_creation_type}" not recognized.'
        )

    auth_manager.upload_final_files()


def run(setup, container_name, image_name, parallel, verbose, ec2):
    # setup, container_name, image_name, parallel, verbose, ec2 = get_parameters()
    if setup:
        print_green(ssl.get_default_verify_paths())
        exit()

    # Remove old error log if present
    if os.path.exists("AutoReports/batch_log.csv"):
        os.remove("AutoReports/batch_log.csv")

    if not ec2:
        azure_login()

    if parallel:
        report_creation_type = "report_shell_parallel"
    else:
        report_creation_type = "report_shell"

    operating_system_type = platform.system().lower()
    if operating_system_type == "darwin" or operating_system_type == "linux":
        operating_system_type = "mac"
    if operating_system_type != "windows" and operating_system_type != "mac":
        # print_red("Error: Detected operating system is not supported.")
        raise RuntimeError("Detected operating system is not supported.")

    try:
        loop = asyncio.get_running_loop()
    except RuntimeError:
        loop = None

    if loop and loop.is_running():
        loop.create_task(
            run_main_and_docker(
                operating_system=operating_system_type,
                report_creation_type=report_creation_type,
                container_name=container_name,
                image_name=image_name,
                verbose=verbose,
                ec2=ec2,
            )
        )
    else:
        asyncio.run(
            run_main_and_docker(
                operating_system=operating_system_type,
                report_creation_type=report_creation_type,
                container_name=container_name,
                image_name=image_name,
                verbose=verbose,
                ec2=ec2,
            )
        )


if __name__ == "__main__":
    setup, container_name, image_name, parallel, verbose, ec2 = get_parameters()
    try:
        if ec2:
            cleanup_container(container_name)
        run(setup, container_name, image_name, parallel, verbose, ec2)
        # exit('\033[1;32mDone!\033[0m')
    # Remove the docker container when the script is forfully terminated
    except KeyboardInterrupt as e:
        print_red("Interrupted")
        cleanup_container(container_name)
        add_err_to_log(e, "MANUAL_INTERRUPT")
        try:
            sys.exit(130)
        except SystemExit:
            os._exit(130)
    # Catch and re-throw all exceptions, removing the docker container before throwing the error
    except subprocess.CalledProcessError as e:
        print_red(f"\nAn error occurred:\n{e.stderr}")
        # cleanup_container(container_name)
        add_err_to_log(e.stderr, "PIPELINE_ERR")
        raise e
    except Exception as e:
        print_red(f"\nAn error occurred:\n{e}")
        # cleanup_container(container_name)
        add_err_to_log(e, "PIPELINE_ERR")
        raise e
    finally:
        if not ec2:
            cleanup_container(container_name)
        if os.path.exists("AutoReports/batch_log.csv"):
            error_df = pd.read_csv("AutoReports/batch_log.csv", dtype=str)
            # Update Airtable
            try:
                print_yellow("Updating airtable statuses...")
                airtable_client = AirtableClient(base_id="app7XUHXU0curFJZM")
                airtable_client.update_v2_status(
                    table_id="tblMjkfDgd9o3ORp8", status_updates_df=error_df
                )
            except Exception as e:
                print_red(
                    f"\nError encountered while attempting to update Airtable: {e}"
                )
                add_err_to_log(e, "AIRTABLE_UPDATE_ERR")
                raise e

            # Send email
            if ec2:
                try:
                    print_yellow("Sending emails...")
                    email_sender = EmailSender(report_log_df=error_df)
                    email_sender.send_to_group()
                except Exception as e:
                    print_red(f"\nError encountered while attempting to send emails: {e}")
                    add_err_to_log(e, "EMAIL_ERR")
                    raise e
