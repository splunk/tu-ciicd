#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <splunkcom_username> <splunk_stack_username> <splunk_stack_password> <local_app_path> <stack_name> <environment> <acs>"
    exit 1 
fi

# Set variables from command-line arguments
SPLUNKCOM_USERNAME="$1"
SPLUNK_STACK_USERNAME="$2"
SPLUNK_STACK_PASSWORD="$3"
LOCAL_APP_PATH="$4"
STACK_NAME="$5"
ENVIRONMENT="$6"
ACS="$7"

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# 1. Generate splunkbase.com token
echo "Generating Splunkbase token..."
SPLUNKBASE_RESPONSE=$(curl -s -u $SPLUNKCOM_USERNAME --url "https://api.splunk.com/2.0/rest/login/splunk")
SPLUNKBASE_TOKEN=$(echo "$SPLUNKBASE_RESPONSE" | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$SPLUNKBASE_TOKEN" ]; then
    echo "Failed to generate Splunkbase token"
    echo "Response: $SPLUNKBASE_RESPONSE"
    exit 1
fi

# echo "Splunkbase token generated successfully"
# 2. Generate Splunk Cloud (stack) token
echo "Generating Splunk Cloud token..."
echo "https://$ENVIRONMENT/$STACK_NAME/$ACS/tokens"
STACK_RESPONSE=$(curl -u $SPLUNK_STACK_USERNAME:$SPLUNK_STACK_PASSWORD \
        -X POST https://$ENVIRONMENT/$STACK_NAME/$ACS/tokens \
        --header 'Content-Type: application/json' \
        --data-raw '{"user" : "'$SPLUNK_STACK_USERNAME'",
                    "for sc_admins" : "install app victoria",
                    "expiresOn" : "+5d",
                    "audience" : "acs-test"}' )
STACK_TOKEN=$(echo "$STACK_RESPONSE" | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$STACK_TOKEN" ]; then
    echo "Failed to generate Splunk Cloud token"
    echo "Response: $STACK_RESPONSE"
    exit 1
fi

echo "Splunk Cloud token generated successfully"

# 3. Install App to the target Stack

echo "Installing app to $STACK_NAME..."
INSTALL_RESPONSE=$(curl -s -X POST "https://$ENVIRONMENT/$STACK_NAME/$ACS/apps/victoria" \
    --header "X-Splunk-Authorization: $SPLUNKBASE_TOKEN" \
    --header "Authorization: Bearer $STACK_TOKEN" \
    --header 'ACS-Legal-Ack: Y' \
    --data-binary "@$LOCAL_APP_PATH")

# Parse the JSON response
STATUS=$(echo "$INSTALL_RESPONSE" | grep -o '"status":"[^"]*' | sed 's/"status":"//')

if [[ $STATUS == "installed" ]]; then
    echo "App installed successfully"
    echo "Response: $INSTALL_RESPONSE"
else
    echo "Failed to install app"
    echo "Response: $INSTALL_RESPONSE"
    exit 1
fi
