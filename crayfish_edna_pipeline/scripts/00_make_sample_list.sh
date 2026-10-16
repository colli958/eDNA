#!/bin/bash

source config.sh

find "$RAW_DIR" \
    -name "*_R1_001.fastq" \
    -exec basename {} _R1_001.fastq \; \
    | sort > "$PROJECT_DIR/sample_list.txt"

echo "Found $(wc -l < $PROJECT_DIR/sample_list.txt) samples"

echo "Checking paired-end files..."

for R1 in $RAW_DIR/*_R1_001.fastq
do
    R2=${R1/_R1_/_R2_}

    if [ ! -f "$R2" ]
    then
        echo "Missing pair:"
        echo "$R2"
        exit 1
    fi
done