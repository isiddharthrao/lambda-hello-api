def lambda_handler(event, context):
    """API Gateway proxy entrypoint. Prints and returns a fixed greeting."""
    print("hello world")
    return {
        "statusCode": 200,
        "headers": {"content-type": "text/plain"},
        "body": "hello world",
    }
