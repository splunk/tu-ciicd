#!/bin/bash

# Check if app_name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <app_name>"
    exit 1
fi

app_name="$1"

# Check if the app directory exists
if [ ! -d "$app_name" ]; then
    echo "Error: Directory '$app_name' not found."
    exit 1
fi

# Get the absolute path of the app directory
app_path=$(cd "$app_name" && pwd)

# Fix file permissions
find "$app_name" -type f -print0 | xargs -0 chmod 644

# Fix directory permissions in bin folder
if [ -d "$app_name/bin" ]; then
    find "$app_name/bin" -type f -print0 | xargs -0 chmod 755
fi

# Delete /metadata/local.meta
if [ -f "$app_name/metadata/local.meta" ]; then
    rm "$app_name/metadata/local.meta"
    echo "Deleted $app_name/metadata/local.meta"
fi

# Remove [install] stanza from default/app.conf
if [ -f "$app_name/default/app.conf" ]; then
    sed -i '' '/^\[install\]/,/^$/d' "$app_name/default/app.conf"
    echo "Removed [install] stanza from $app_name/default/app.conf"
fi

# Create the tarball
COPYFILE_DISABLE=1 GZIP=-9 tar \
    --exclude="local" \
    --exclude=".*" \
    --exclude="local.meta" \
    --exclude="*.pyc" \
    --exclude="__pycache__" \
    --exclude="passwords.conf" \
    --format=ustar \
    -zcvf "${app_name}.tgz" -C "$(dirname "$app_path")" "$(basename "$app_path")" # This ensures that we're always working with the full path, regardless of how it was input

echo "Package created: ${app_name}.tgz"
