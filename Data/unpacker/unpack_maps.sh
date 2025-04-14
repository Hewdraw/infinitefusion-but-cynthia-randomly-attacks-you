#!/bin/bash

set -e

# Get script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Input: where the map files are
INPUT_DIR="$SCRIPT_DIR/../"
# Output: where to unpack
OUTPUT_DIR="$SCRIPT_DIR/unpacked"

echo "📂 Script directory: $SCRIPT_DIR"
echo "🔍 Looking for .rxdata files in: $INPUT_DIR"
ls -l "$INPUT_DIR"

# Create output dir if needed
mkdir -p "$OUTPUT_DIR"

# Find map files
map_files=()
while IFS= read -r -d '' file; do
  map_files+=("$file")
done < <(find "$INPUT_DIR" -maxdepth 1 -type f -name 'Map*.rxdata' -print0)

# Error if none found
if [ ${#map_files[@]} -eq 0 ]; then
  echo "❌ No Map*.rxdata files found in $INPUT_DIR"
  exit 1
fi

echo "📄 Found the following map files:"
for file in "${map_files[@]}"; do
  echo "  - $file"
done

# Pass files to fusionpacker in manageable chunks using xargs
echo "🚀 Running fusionpacker..."

# Use xargs to split the command and avoid path too long errors
printf "%s\n" "${map_files[@]}" | xargs -n 10 fusionpacker --force --project-type xp --action unpack --project "$OUTPUT_DIR"

echo "✅ Maps unpacked to: $OUTPUT_DIR"
