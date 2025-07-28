import json
import boto3
import logging
import os

# Initialize the EC2 client
ec2_client = boto3.client('ec2')

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def lambda_handler(event, context):
    # Handle project_name from pathParameters if present (for API Gateway), else use the root of event (for Step Function)
    project_name = event.get('pathParameters', {}).get('project_name', event.get('project_name', None))
    
    if project_name != 'ILNA':
        return error_response('ILNA not triggered correctly')

    instance_id = get_instance_id()
    if not instance_id:
        return error_response('Error: INSTANCE_ID environment variable not set')
        
    # Start EC2 instance and wait for it to run
    start_ec2_instance(instance_id)
    
    # Send initial success response
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps({
            'message': 'Reports generation process started successfully',
            'status': 'Process initiated',
            'instance_id': instance_id
        })
    }

# Helper function to handle error responses
def error_response(message):
    return {
        'statusCode': 400,
        'headers': {
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps({
            'error': message
        })
    }

# Function to get the EC2 instance ID from environment variables
def get_instance_id():
    return os.getenv('INSTANCE_ID')

# Function to start the EC2 instance
def start_ec2_instance(instance_id):
    try:
        # Check the current state of the instance
        response = ec2_client.describe_instances(InstanceIds=[instance_id])
        instance_state = response['Reservations'][0]['Instances'][0]['State']['Name']

        if instance_state == 'running':
            logger.info(f"EC2 instance {instance_id} is already running")
            return

        # Start the instance if it is not running
        ec2_client.start_instances(InstanceIds=[instance_id])
        logger.info(f"Starting EC2 instance: {instance_id}")
        
        # Wait until the instance is running
        ec2_client.get_waiter('instance_running').wait(InstanceIds=[instance_id])
        logger.info(f"EC2 instance {instance_id} is now running")

    except Exception as e:
        logger.error(f"Error occurred while starting EC2 instance: {str(e)}")
        raise
