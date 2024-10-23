#!/bin/bash

# Add debug output
echo "Debug: Received arguments: $@"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -package) APP_PACKAGE="$2"; shift 2 ;;
    -host) SPLUNK_HOST="$2"; shift 2 ;;
    -user) SPLUNK_USER="$2"; shift 2 ;;
    -password) SPLUNK_PASSWORD="$2"; shift 2 ;;
    -target) TARGET_URI="$2"; shift 2 ;;
    -adminuser) ADMIN_USER="$2"; shift 2 ;;
    -adminpassword) ADMIN_PASSWORD="$2"; shift 2 ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

# Add debug output for parsed variables
echo "Debug: APP_PACKAGE=$APP_PACKAGE"
echo "Debug: SPLUNK_HOST=$SPLUNK_HOST"
echo "Debug: SPLUNK_USER=$SPLUNK_USER"
echo "Debug: SPLUNK_PASSWORD=$SPLUNK_PASSWORD"
echo "Debug: TARGET_URI=$TARGET_URI"
echo "Debug: ADMIN_USER=$ADMIN_USER"
echo "Debug: ADMIN_PASSWORD=$ADMIN_PASSWORD"

# Check if required arguments are provided
if [ -z "$APP_PACKAGE" ] || [ -z "$SPLUNK_HOST" ] || [ -z "$SPLUNK_USER" ] || [ -z "$SPLUNK_PASSWORD" ] || [ -z "$TARGET_URI" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASSWORD" ]; then
    echo "Error: Missing required arguments"
    echo "Usage: $0 \\"
    echo "  -package <app_name> \\"
    echo "  -host <splunk_host> \\"
    echo "  -user <splunk_user> \\"
    echo "  -password <splunk_password> \\"
    echo "  -target <target_uri> \\"
    echo "  -adminuser <admin_user> \\"
    echo "  -adminpassword <admin_password>"   
    exit 1
fi

# Check if the app directory exists
if [ ! -d "$APP_PACKAGE" ]; then
    echo "Error: Directory '$APP_PACKAGE' not found."
    exit 1
fi

# Fix file permissions
find "$APP_PACKAGE" -type f -print0 | xargs -0 chmod 644

# Fix directory permissions in bin folder
if [ -d "$APP_PACKAGE/bin" ]; then
    find "$APP_PACKAGE/bin" -type f -print0 | xargs -0 chmod 755
fi

# Delete /metadata/local.meta
if [ -f "$APP_PACKAGE/metadata/local.meta" ]; then
    rm "$APP_PACKAGE/metadata/local.meta"
    echo "Deleted $APP_PACKAGE/metadata/local.meta"
fi

# Remove [install] stanza from default/app.conf
if [ -f "$APP_PACKAGE/default/app.conf" ]; then
    awk '
        BEGIN {in_install = 0}
        /^\[install\]/ {in_install = 1; next}
        /^\[/ && in_install {in_install = 0}
        !in_install {print}
    ' "$APP_PACKAGE/default/app.conf" > "$APP_PACKAGE/default/app.conf.tmp" &&
    mv "$APP_PACKAGE/default/app.conf.tmp" "$APP_PACKAGE/default/app.conf"
    echo "Removed [install] stanza from $APP_PACKAGE/default/app.conf"
fi

# Bump app version
./bump-app-version.sh "$APP_PACKAGE"

# Create the tarball
COPYFILE_DISABLE=1 GZIP=-9 tar \
    --exclude=".*" \
    --exclude="*.pyc" \
    --exclude="__pycache__" \
    --exclude="passwords.conf" \
    --format=ustar \
    -zcvf "${APP_PACKAGE}.tgz" -C "$(dirname "$APP_PACKAGE")" "$(basename "$APP_PACKAGE")" # This ensures that we're always working with the full path, regardless of how it was input

# Transfer the app package to the remote server
scp -o StrictHostKeyChecking=no "${APP_PACKAGE}.tgz" ${SPLUNK_USER}@${SPLUNK_HOST}:/tmp/
echo "Transferred ${APP_PACKAGE}.tgz to deployer"

# SSH to Splunk instance and run commands to install the app and apply the shcluster bundle
ssh -t -o StrictHostKeyChecking=no ${SPLUNK_USER}@${SPLUNK_HOST} << EOF
    sudo su - splunk
 
    tar -xzf /tmp/${APP_PACKAGE}.tgz -C /opt/splunk/etc/shcluster/apps/
    echo "Extracted ${APP_PACKAGE} to /opt/splunk/etc/shcluster/apps/"

    /opt/splunk/bin/splunk apply shcluster-bundle -target $TARGET_URI -auth $ADMIN_USER:$ADMIN_PASSWORD --answer-yes
    rm /tmp/${APP_PACKAGE}.tgz  # Clean up the temporary file

    # Write the bundle name to a temporary file
    sudo chmod 644 /opt/splunk/var/run/splunk/deploy/apps/${APP_PACKAGE}-*.bundle
    ls -t /opt/splunk/var/run/splunk/deploy/apps/${APP_PACKAGE}-*.bundle | head -n1 > /tmp/bundle_name.txt
    chmod 644 /tmp/bundle_name.txt  # Ensure the file is readable
EOF

# Retrieve the bundle name from the temporary file
BUNDLE_NAME=$(ssh -o StrictHostKeyChecking=no ${SPLUNK_USER}@${SPLUNK_HOST} "cat /tmp/bundle_name.txt")

# Check if BUNDLE_NAME is empty
if [ -z "$BUNDLE_NAME" ]; then
    echo "Error: Unable to retrieve bundle name. Exiting."
    exit 1
fi

echo "Bundle name: ${BUNDLE_NAME}"

# Use ssh to cat the file with sudo and redirect to local file
echo "Attempting to copy bundle from remote server..."
ssh -o StrictHostKeyChecking=no ${SPLUNK_USER}@${SPLUNK_HOST} "sudo cat ${BUNDLE_NAME}" > ./${APP_PACKAGE}.tgz
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy bundle from remote server."
    echo "Debugging information:"
    ssh -o StrictHostKeyChecking=no ${SPLUNK_USER}@${SPLUNK_HOST} "sudo ls -l ${BUNDLE_NAME}"
    exit 1
fi

echo "Successfully copied bundle from remote server."

# Clean up the temporary file on the remote server
ssh -o StrictHostKeyChecking=no ${SPLUNK_USER}@${SPLUNK_HOST} "sudo rm /tmp/bundle_name.txt"
echo "Cleaned up bundle_name.txt on remote server"
