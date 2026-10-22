#!/bin/bash --login

set -euo pipefail

###############################################################################
# Load configuration
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PIPELINE_DIR="$( dirname "$SCRIPT_DIR" )"

source "${PIPELINE_DIR}/config/config.sh"

###############################################################################
# Create output directories
###############################################################################

mkdir -p "$TRIM_DIR"
mkdir -p "$CUTADAPT_LOG_DIR"

###############################################################################
# Verify sample list exists
###############################################################################

SAMPLE_LIST="$PROJECT_DIR/sample_list.txt"

if [ ! -f "$SAMPLE_LIST" ]; then
    echo "ERROR: Cannot find $SAMPLE_LIST"
    echo "Run 00_make_sample_list.sh first."
    exit 1
fi

###############################################################################
# Count samples
###############################################################################

N=$(wc -l < "$SAMPLE_LIST")

echo "Found $N samples in sample_list.txt" >&2

if [ "$N" -eq 0 ]; then
    echo "ERROR: sample_list.txt is empty."
    exit 1
fi

###############################################################################
# Check whether trimmed files already exist
###############################################################################

MISSING=0

while read -r SAMPLE; do
    FWD="${TRIM_DIR}/${SAMPLE}_trimmed_R1.fastq.gz"
    REV="${TRIM_DIR}/${SAMPLE}_trimmed_R2.fastq.gz"

    if [[ ! -f "$FWD" || ! -f "$REV" ]]; then
        MISSING=1
        break
    fi
done < "$SAMPLE_LIST"

if [[ "$MISSING" -eq 0 ]]; then
    echo "Skipping cutadapt."
    exit 0
fi

###############################################################################
# Submit cutadapt array
###############################################################################

echo "Submitting cutadapt array job..." >&2

JOBID=$(sbatch \
    --export=ALL,PIPELINE_DIR="$PROJECT_DIR" \
    --output="$CUTADAPT_LOG_DIR/cutadapt_%A_%a.out" \
    --error="$CUTADAPT_LOG_DIR/cutadapt_%A_%a.err" \
    --array=1-${N} \
    scripts/cutadapt_array.sb | awk '{print $4}')
    
    echo "Submitted cutadapt job: $JOBID" >&2

if [[ ! "$JOBID" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Failed to retrieve valid job ID" >&2
    exit 1
fi

echo "$JOBID"