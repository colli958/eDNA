#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PIPELINE_DIR="$( dirname "$SCRIPT_DIR" )"

source "${PIPELINE_DIR}/config/config.sh"

find "$RAW_DIR" \
    -name "*_R1_001.fastq" \
    | sed 's/_R1_001.fastq$//' \
    | xargs -n1 basename \
    | sort \
    > "$PROJECT_DIR/sample_list.txt"

echo "Created sample list:"
wc -l "$PROJECT_DIR/sample_list.txt"

cat "$PROJECT_DIR/sample_list.txt"