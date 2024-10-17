# Check if correct number of arguments are provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <app_id> <splunk_stack_username> <splunk_stack_password> <stack_name> <environment> <acs> <output_file_name>"
    exit 1 
fi

# Set variables from command-line arguments
APP_ID="$1"
SPLUNK_STACK_USERNAME="$2"
SPLUNK_STACK_PASSWORD="$3"
STACK_NAME="$4"
ENVIRONMENT="$5"
ACS="$6"
OUTPUT_FILE_NAME="$7"

# Generate Splunk Cloud (stack) token
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

# Export the app using ACS API
echo "Exporting app..."
EXPORT_RESPONSE=$(curl -X GET "https://$ENVIRONMENT/$STACK_NAME/$ACS/apps/victoria/export/download/$APP_ID?local=true&default=false&users=true" \
    --header "Authorization: Bearer $STACK_TOKEN" \
    --output "$OUTPUT_FILE_NAME.tar.gz")

if [ $? -eq 0 ]; then
    echo "App exported successfully to $OUTPUT_FILE_NAME.tar.gz"
else
    echo "Failed to export app"
    echo "Response: $EXPORT_RESPONSE"
    exit 1
fi
