#!/bin/bash

# Define the directory to search
IMAGE_DIR="/home/fabrizio/images"

# Find and delete files older than a day with ".wic" but not ".bz2" in the filename
find "$IMAGE_DIR" -type f -name "*.wic" ! -name "*.bz2" -mtime +1 -delete

# Find the most recent ".wic.bz2" file in each folder and delete the older ones
find "$IMAGE_DIR" -type f -name "*.wic.bz2" | while IFS= read -r file; do
        # Get the directory of the file
        dir=$(dirname "$file")
        # Get the most recent .wic.bz2 file in the directory
        most_recent=$(ls -t "$dir"/*.wic.bz2 2>/dev/null | head -n1)
        # Delete the file if it's not the most recent
        if [[ "$file" != "$most_recent" ]]; then
            echo "Deleting $file"
            rm "$file"
        fi
    done



