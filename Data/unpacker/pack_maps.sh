#!/bin/bash

# Exit on error
set -e

echo "📂 Current working directory: $(pwd)"
echo "🔍 Listing contents of ../:"
ls -l ../

# Define input/output
INPUT_DIR="../."
OUTPUT_DIR="./unpacked"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Find Map*.rxdata files in INPUT_DIR
map_files=($(find "$INPUT_DIR" -maxdepth 1 -type f -name 'Map*.rxdata'))

# Debug: print raw file list
echo "🧪 Raw find output: ${map_files[*]}"

# Check if any map files were found
if [ ${#map_files[@]} -eq 0 ]; then
  echo "❌ No Map*.rxdata files found in $INPUT_DIR"
  exit 1
fi

# Print found files
echo "📄 Found the following map files:"
for file in "${map_files[@]}"; do
  echo "  - $file"
done

# Join files with commas
FILE_LIST=$(IFS=,; echo "${map_files[*]}")

# Run fusionpacker
echo "🚀 Running fusionpacker..."
bundle exec fusionpacker --force \
  --files "$FILE_LIST" \
  --project-type xp \
  --action unpack \
  --project "$OUTPUT_DIR"

echo "✅ Maps unpacked to: $OUTPUT_DIR"
