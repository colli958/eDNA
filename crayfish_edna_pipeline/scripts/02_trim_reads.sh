#!/bin/bash

source config.sh

mkdir -p "$TRIM_DIR"
mkdir -p "$PROJECT_DIR/qstat/cutadapt"

# Generate sample list
find "$RAW_DIR" \
    -name "*_R1_001.fastq" \
    -exec basename {} _R1_001.fastq \; \
    | sort > "$PROJECT_DIR/sample_list.txt"

N=$(wc -l < "$PROJECT_DIR/sample_list.txt")

echo "Found $N samples"

if [ "$N" -eq 0 ]; then
    echo "ERROR: No samples found."
    exit 1
fi

echo "Submitting cutadapt array job..."

sbatch \
    --array=1-"$N" \
    cutadapt_array.sb
