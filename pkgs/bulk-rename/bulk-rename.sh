#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: bulk-rename [directory]"
    echo "       bulk-rename [file1 file2 ...]"
    echo ""
    echo "If files are provided as arguments, they will be renamed."
    echo "If a directory is provided, all files in that directory will be renamed."
    echo "If no arguments are provided, files in current directory will be renamed."
}

# Function to cleanup temporary files
cleanup() {
    [ -n "$index" ] && [ -f "$index" ] && rm -f "$index"
    [ -n "$index_edit" ] && [ -f "$index_edit" ] && rm -f "$index_edit"
}

# Set trap to ensure cleanup on exit
trap cleanup EXIT

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Create temporary files
index=$(mktemp /tmp/bulk-rename-index.XXXXXXXXXX) || exit 1
index_edit=$(mktemp /tmp/bulk-rename.XXXXXXXXXX) || exit 1

# Determine target directory and what files to rename
target_dir="."
if [ $# -eq 0 ]; then
    # No arguments - use current directory
    shopt -s nullglob dotglob
    files=(*)
    if [ ${#files[@]} -gt 0 ]; then
        printf '%s\n' "${files[@]}" > "$index"
    fi
elif [ -d "$1" ] && [ $# -eq 1 ]; then
    # Single directory argument
    target_dir="$1"
    if [ "$target_dir" = "." ]; then
        target_dir="$(pwd)"
    fi
    shopt -s nullglob dotglob
    files=("$target_dir"/*)
    # Extract just the filenames
    for file in "${files[@]}"; do
        [ -e "$file" ] && basename "$file"
    done | sort > "$index"
else
    # File arguments - assume current directory for now
    # TODO: Handle files from different directories properly
    for file in "$@"; do
        if [ -e "$file" ]; then
            basename "$file"
        else
            echo "Warning: $file does not exist" >&2
        fi
    done > "$index"
fi

# Check if we have any files to rename
if [ ! -s "$index" ]; then
    echo "No files to rename"
    exit 0
fi

# Copy index to edit file
cat "$index" > "$index_edit"

# Get editor (same priority as lf)
EDITOR="${EDITOR:-${VISUAL:-vi}}"

# Open editor
"$EDITOR" "$index_edit"

# Check if line counts match
original_lines=$(wc -l < "$index")
edited_lines=$(wc -l < "$index_edit")

if [ "$original_lines" -ne "$edited_lines" ]; then
    echo "Error: Number of lines must stay the same ($original_lines -> $edited_lines)" >&2
    exit 1
fi

# Process the renames
echo "Processing renames in $target_dir..."
success_count=0
error_count=0

max=$((original_lines + 1))
counter=1

while [ $counter -le $max ]; do
    a=$(sed "${counter}q;d" "$index")
    b=$(sed "${counter}q;d" "$index_edit")
    
    counter=$((counter + 1))
    
    # Skip if names are the same
    [ "$a" = "$b" ] && continue
    
    # Full paths for source and destination
    source_path="$target_dir/$a"
    dest_path="$target_dir/$b"
    
    # Check if destination already exists
    if [ -e "$dest_path" ]; then
        echo "Error: File exists: $b" >&2
        error_count=$((error_count + 1))
        continue
    fi
    
    # Check if source exists
    if [ ! -e "$source_path" ]; then
        echo "Error: Source file does not exist: $a" >&2
        error_count=$((error_count + 1))
        continue
    fi
    
    # Perform rename
    if mv "$source_path" "$dest_path"; then
        echo "Renamed: $a -> $b"
        success_count=$((success_count + 1))
    else
        echo "Error: Failed to rename $a -> $b" >&2
        error_count=$((error_count + 1))
    fi
done

echo "Summary: $success_count successful, $error_count errors"

# Exit with error code if there were errors
[ $error_count -gt 0 ] && exit 1 || exit 0
