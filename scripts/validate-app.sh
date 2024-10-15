#!/bin/bash

show_response_message() {
    local response="$1"
    local message=""

    # Look for 'msg' or 'message' in the response
    if [[ $response == *"msg"* ]]; then
        message=$(echo "$response" | sed -n 's/.*"msg":"\([^"]*\)".*/\1/p')
    elif [[ $response == *"message"* ]]; then
        message=$(echo "$response" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p')
    else
        message="No message found in the response"
    fi

    echo "$message"
}

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <username> <app_package_path> <output_file_name>"
    exit 1
fi

# Set variables from command-line arguments
USERNAME="$1"
APP_PACKAGE_PATH="$2"
OUTPUT_FILE_NAME="$3"
# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Step 1: Authenticate and get token
echo "Authenticating with Splunk API..."
AUTH_RESPONSE=$(curl -s -u "$USERNAME" --url "https://api.splunk.com/2.0/rest/login/splunk")
check_success "Authentication failed"

show_response_message "$AUTH_RESPONSE"

TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"token":"[^"]*' | sed 's/"token":"//')
if [ -z "$TOKEN" ]; then
    echo "Error: Failed to extract token from response"
    exit 1
fi

# Step 2: Submit app package for validation
echo "Submitting app package for validation..."
VALIDATE_RESPONSE=$(curl -s -X POST \
     -H "Authorization: bearer $TOKEN" \
     -H "Cache-Control: no-cache" \
     -F "app_package=@$APP_PACKAGE_PATH" \
     -F "included_tags=cloud,self-service" \
     -F "excluded_tags=splunk-appinspect" \
     --url "https://appinspect.splunk.com/v1/app/validate")
check_success "App submission failed"

show_response_message "$VALIDATE_RESPONSE"

REQUEST_ID=$(echo "$VALIDATE_RESPONSE" | grep -o '"request_id": "[^"]*' | cut -d'"' -f4)
if [ -z "$REQUEST_ID" ]; then
    echo "Error: Failed to extract request ID from response"
    exit 1
fi

echo "App package submitted. Request ID: $REQUEST_ID"

# Step 3: Check validation status
echo "Checking validation status..."
while true; do
    STATUS_RESPONSE=$(curl -s -X GET \
        -H "Authorization: bearer $TOKEN" \
        --url "https://appinspect.splunk.com/v1/app/validate/status/$REQUEST_ID")
    check_success "Status check failed"

    STATUS=$(echo "$STATUS_RESPONSE" | grep -o '"status": "[^"]*' | cut -d'"' -f4)
    echo "Current status: $STATUS"

    if [ "$STATUS" = "SUCCESS" ]; then
        break
    elif [ "$STATUS" = "FAILURE" ]; then
        echo "Validation failed. Exiting."
        exit 1
    fi

    echo "Waiting 10 seconds before checking again..."
    sleep 10
done

# Step 4: Retrieve validation report
echo "Retrieving validation report..."
REPORT_RESPONSE=$(curl -s -X GET \
     -H "Authorization: bearer $TOKEN" \
     -H "Cache-Control: no-cache" \
     -H "Content-Type: text/html" \
     --url "https://appinspect.splunk.com/v1/app/report/$REQUEST_ID")
check_success "Report retrieval failed"

show_response_message "$REPORT_RESPONSE"

echo "$REPORT_RESPONSE" > $OUTPUT_FILE_NAME.html

echo "Report saved to $OUTPUT_FILE_NAME.html"
