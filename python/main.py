#!/usr/bin/env python
from datetime import datetime

def lambda_handler(event, context):
    curr_time = datetime.now().strftime("%H:%M:%S")
    status=200
    headers= {'Content-Type': 'application/json'}
    return {
        'statusCode': status,
        'headers': headers,
        'body': curr_time
    }



if __name__ == '__main__':
    # Do nothing if executed as a script
    pass
