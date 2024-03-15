#!/bin/bash

# Function to print directory tree and disk usage
print_directory_tree() {
    local directory="$1"
    local min_size="$2"

    # Get disk usage of the directory
    dir_size=$(du -s "$directory" 2>/dev/null | cut -f1)

    # Check if directory size is a valid number
    if [[ "$dir_size" =~ ^[0-9]+$ ]]; then
        # Check if directory size is greater than the specified minimum size (in KB)
        if [ "$dir_size" -gt "$min_size" ]; then
            # Print disk usage of the directory
	    echo "Disk usage of $directory: $(du -sh $directory 2> /dev/null | awk '{print $1}')"

            # Print directory tree excluding files
            find "$directory" -mindepth 1 -maxdepth 1 -type d -exec bash -c '
                print_directory_tree "$1" "$2"
            ' bash {} "$min_size" \;
        fi
    else
        echo "Warning: Invalid or inaccessible directory: $directory"
    fi
}

# Export the function so that it's available to subshells
export -f print_directory_tree

# Root directory to print the directory tree
root_directory="/"

# Minimum size threshold in KB (1 GB)
min_size_threshold=$((1024 * 1024))

# Print directory tree and disk usage for the root directory
print_directory_tree "$root_directory" "$min_size_threshold"

