import logging
import json

# Set up logging
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def handler(event, context):
    try:
        LOGGER.info('SQS EVENT: %s', event)

        for sqs_rec in event['Records']:
            # Extract the S3 event from the SQS record
            s3_event = json.loads(sqs_rec['body'])

            # Check if the S3 event is a test event
            if 'Event' in s3_event and s3_event['Event'] == 's3:TestEvent':
                # If it's a test event, skip logging and continue with the next SQS record
                continue

            # Log the S3 event details
            LOGGER.info('S3 EVENT: %s', s3_event)

            # Log additional information for each S3 record
            for s3_rec in s3_event['Records']:
                bucket_name = s3_rec['s3']['bucket']['name']
                object_key = s3_rec['s3']['object']['key']

                LOGGER.info('Bucket name: %s', bucket_name)
                LOGGER.info('Object key: %s', object_key)

    except Exception as exception:
        # Log exceptions
        LOGGER.error('Exception: %s', exception)
        raise