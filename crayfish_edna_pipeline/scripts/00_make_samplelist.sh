#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PIPELINE_DIR="$( dirname "$SCRIPT_DIR" )"

source "${PIPELINE_DIR}/config/config.sh"

mkdir -p "$DB_DIR"
mkdir -p "$TRIM_DIR"
mkdir -p "$PLOT_DIR"
mkdir -p "$DADA2_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$CUTADAPT_LOG_DIR"

echo "Pipeline directories initialized"

find "$RAW_DIR" \
    -name "*_R1_001.fastq" \
    | sed 's/_R1_001.fastq$//' \
    | xargs -n1 basename \
    | sort \
    > "$PROJECT_DIR/sample_list.txt"

echo "Created sample list:"
wc -l "$PROJECT_DIR/sample_list.txt"

cat "$PROJECT_DIR/sample_list.txt"
