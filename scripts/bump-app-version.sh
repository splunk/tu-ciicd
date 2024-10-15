#!/bin/bash

# Function to increment version
increment_version() {
    local version=$1
    local suffix=""

    # Extract suffix if present
    if [[ $version == *"+"* ]] || [[ $version == *"-"* ]]; then
        suffix=$(echo $version | grep -oE '[-+][a-zA-Z]+$')
        version=${version%$suffix}
    fi

    # Split version into parts
    IFS='.' read -ra version_parts <<< "$version"
    # Increment the last numeric part
    last_index=$((${#version_parts[@]} - 1))
    version_parts[$last_index]=$((version_parts[last_index] + 1))

    # Reconstruct version
    new_version=$(IFS=.; echo "${version_parts[*]}")
    new_version+=$suffix

    echo $new_version
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <app_folder>"
    exit 1
fi

app_folder="$1"
conf_file="$app_folder/default/app.conf"

echo "conf_file: $conf_file"
# Check if the app.conf file exists
if [ ! -f "$conf_file" ]; then
    echo "Error: app.conf not found in $conf_file"
    exit 1
fi

# Extract the current version
current_version=$(grep "version = " "$conf_file" | head -n 1 | cut -d= -f2 | tr -d '[:space:]')

if [ -z "$current_version" ]; then
    echo "Error: Version not found in app.conf"
    exit 1
fi

# Validate version format
if ! [[ $current_version =~ ^[0-9]+(\.[0-9]+)*(-|\+)?[a-zA-Z]*$ ]]; then
    echo "Error: Invalid version format in app.conf"
    exit 1
fi

echo "current_version: $current_version"
# Increment the version
new_version=$(increment_version "$current_version")

# Update the version in the file (both occurrences)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version = .*/version = $new_version/g" "$conf_file"
else
    # Linux and others
    sed -i "s/^version = .*/version = $new_version/g" "$conf_file"
fi

echo "Version bumped from $current_version to $new_version"
