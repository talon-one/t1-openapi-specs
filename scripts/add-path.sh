#!/bin/bash

# A script to find all .yml and .yaml files in a directory and prepend
# a comment with their relative path, replacing an existing path line if found.

# Check if a target directory was provided as an argument.
if [ -z "$1" ]; then
    echo "Error: Please provide a target directory as an argument."
    echo "Usage: $0 <targetDir>"
    exit 1
fi

targetDir="$1"

# Check if the provided directory exists and is a directory.
if [ ! -d "$targetDir" ]; then
    echo "Error: Directory '$targetDir' not found."
    exit 1
fi

echo "Scanning for YAML files in '$targetDir'..."

# Use 'find' to locate all files with .yml or .yaml extensions.
# The 'while read -r' loop processes each file path found by 'find'.
find "$targetDir" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r filePath; do
    # Get the relative path of the file from the target directory.
    # The 'cut' command is used here to remove the base path,
    # which is the targetDir name and the trailing slash.
    relativePath="${filePath#$targetDir/}"

    echo "Processing file: $filePath"

    # Remove the .yaml or .yml file extension.
    finalPath="${relativePath%.yml}"
    finalPath="${finalPath%.yaml}"

    # Construct the new line to be added to the file.
    newLine="# path: /$finalPath"

    # Create a temporary file to hold the new content.
    tempFile=$(mktemp)

    # Check if the first line of the file is already a "# path:" line.
    firstLine=$(head -n 1 "$filePath")

    if [[ "$firstLine" == "# path:"* ]]; then
        # If it's an existing path line, replace it.
        # Get all lines from the second line onwards and prepend the new line.
        echo "$newLine" > "$tempFile"
        tail -n +2 "$filePath" >> "$tempFile"
    else
        # If no existing path line, just prepend the new line.
        echo "$newLine" > "$tempFile"
        cat "$filePath" >> "$tempFile"
    fi

    # Overwrite the original file with the content of the temporary file.
    mv "$tempFile" "$filePath"
done

echo "Script finished."
