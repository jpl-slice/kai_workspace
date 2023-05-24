#!/bin/bash

# Check that at least source and destination directories are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <source_directory> <destination_directory> [file_extension]"
  exit 1
fi

# Store source and destination directories
SOURCE_DIR="$1"
DESTINATION_DIR="$2"

# Store file extension, defaulting to ".txt" if not provided
if [ $# -eq 3 ]; then
  FILE_EXTENSION="$3"
else
  FILE_EXTENSION=".txt"
fi

# Create destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Check if find command returns any files before executing rest of command
if ! find "$SOURCE_DIR" -type f -name "*$FILE_EXTENSION" -print0 | read -r -d '' ; then
  echo "No files found with the specified extension in the source directory"
  exit 1
fi

# Create symbolic links with progress
find "$SOURCE_DIR" -type f -name "*$FILE_EXTENSION" -print0 | pv -pterb | xargs -0 ln -sfP -t "$DESTINATION_DIR"
