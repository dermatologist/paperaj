#!/bin/bash
# converts DOCX to markdown
# Takes 2 command line arguments
# 1 is the docx file to be processed
# 2 is the output markdown file

DOCX=$1
OUTPUT=$2

# Check if arguments are supplied
if [ -z "$DOCX" ] || [ -z "$OUTPUT" ]; then
  echo "Usage: $0 <docx-file> <output-markdown-file>"
  exit 1
fi

# Convert DOCX to Markdown
pandoc -f docx -t markdown "$DOCX" -o "$OUTPUT"

# Echo completion message
echo "Conversion complete: $DOCX -> $OUTPUT"
