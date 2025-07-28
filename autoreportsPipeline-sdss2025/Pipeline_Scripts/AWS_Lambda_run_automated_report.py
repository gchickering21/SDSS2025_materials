import json
import boto3
import logging
import time
import os
import re
import time 

# Initialize EC2 and SSM clients
ec2_client = boto3.client('ec2')
ssm_client = boto3.client('ssm')

# Configure logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
ch.setFormatter(formatter)
logger.addHandler(ch)


def lambda_handler(event, context):
    logger.info("🚀 Lambda function triggered.")

    try:
        instance_id = get_instance_id()
        logger.info(f"✅ Fetched Instance ID: {instance_id}")

        if not instance_id:
            logger.error("❌ Environment variable INSTANCE_ID not set.")
            return error_response("Error: INSTANCE_ID environment variable not set.")

        # Ensure EC2 instance is running
        if not wait_for_ec2_running(instance_id):
            logger.error(f"❌ EC2 instance {instance_id} failed to start.")
            return error_response(f"EC2 instance {instance_id} failed to start.")

        logger.info(f"✅ EC2 instance {instance_id} is running.")

        # Execute SSM command
        response = execute_ssm_command(instance_id)
        logger.info("✅ Lambda execution completed.")
        return response

    except Exception as e:
        logger.error(f"❌ Unexpected error: {e}")
        return error_response(f"Internal Server Error: {str(e)}")


# Function to ensure EC2 is running
def wait_for_ec2_running(instance_id, max_retries=5, wait_time=10):
    retry_count = 0

    while retry_count < max_retries:
        logger.info(f"🔄 Checking if EC2 {instance_id} is running... (Attempt {retry_count + 1})")

        try:
            response = ec2_client.describe_instances(InstanceIds=[instance_id])
            instance_state = response['Reservations'][0]['Instances'][0]['State']['Name']
            logger.info(f"✅ Instance {instance_id} is in state {instance_state}")

            if instance_state == 'running':
                return True
        except Exception as e:
            logger.error(f"❌ Error checking instance state: {e}")

        time.sleep(wait_time)
        retry_count += 1

    return False


# Function to get instance ID from environment
def get_instance_id():
    return os.getenv('INSTANCE_ID')


import json
from datetime import datetime

def convert_datetime(obj):
    """ Convert datetime objects to a string format for JSON serialization. """
    if isinstance(obj, datetime):
        return obj.isoformat()  # Convert datetime to string
    raise TypeError("Type not serializable")

import time  # Ensure time is imported

def execute_ssm_command(instance_id):
    try:
        
        command = """
        sudo su - root -c "
        cd /root/dsaa-autoreports-ILNA && \
        git pull && \
        python3 run_all_scripts.py --parallel --ec2"
        """

        ssm_response = ssm_client.send_command(
            InstanceIds=[instance_id],
            DocumentName="AWS-RunShellScript",
            Parameters={'commands': [command]},
            TimeoutSeconds=900
        )
        

        command_id = ssm_response['Command']['CommandId']
        logger.info(f"✅ SSM Command ID: {command_id}")

        # ✅ Fix: Add delay before polling (SSM takes time to register commands)
        time.sleep(5)

        return poll_ssm_output(command_id, instance_id)

    except Exception as e:
        logger.error(f"❌ Error executing SSM command: {e}")
        return error_response(f"Error: {str(e)}")




# Function to remove ANSI escape codes
def clean_ansi_escape_codes(text):
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)


# Function to poll SSM command output
def poll_ssm_output(command_id, instance_id):
    max_retries = 30 
    retry_count = 0

    while retry_count < max_retries:
        try:
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id,
                PluginName='aws:runShellScript'
            )

            stdout = clean_ansi_escape_codes(output.get('StandardOutputContent', '').strip())
            stderr = clean_ansi_escape_codes(output.get('StandardErrorContent', '').strip())
            status = output.get('Status', 'Unknown')

            # ✅ Log the full raw SSM output for debugging
            logger.info(f"🔍 Full SSM Command Output:\n{repr(stdout)}") 

            # ✅ Updated to strip extra spaces/newlines and lowercase for matching
            if "successfully connected to database" in stdout.lower():
                logger.info("✅ Log message found: 'Successfully connected to database'")
                return success_response(output)

            if stderr and status not in ['Success', 'Failed']:
                logger.error(f"❌ SSM Command Errors:\n{stderr}")

            if status in ['Success', 'Failed']:
                logger.info(f"🛑 SSM Command finished with status: {status}")
                break

        except Exception as e:
            logger.error(f"❌ Error polling SSM output: {e}")

        time.sleep(5)
        retry_count += 1

    return error_response("❌ Expected log message not found: 'Successfully connected to database'")


# Success response function
def success_response(output):
    return {
        'statusCode': 200,
        'headers': {'Access-Control-Allow-Origin': '*'},
        'body': json.dumps({
            'message': '✅ Lambda successfully triggered!',
            'command_status': output['Status'],
            'stdout': output['StandardOutputContent'],
            'stderr': output['StandardErrorContent']
        })
    }


# Error response function
def error_response(message):
    return {
        'statusCode': 500,
        'headers': {'Access-Control-Allow-Origin': '*'},
        'body': json.dumps({'error': message})
    }
