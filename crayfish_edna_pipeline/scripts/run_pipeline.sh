#!/bin/bash

source config/config.sh

echo "Step 0: Create a sample list file"
bash scripts/00_make_sample_list.sh

echo "Step 1: Build reference database"
bash scripts/01_build_reference.sh

echo "Step 2: Trim reads"
bash scripts/02_trim_reads.sh

echo "Waiting for trimming to finish..."

echo "Step 3: DADA2"
Rscript scripts/03_dada2_pipeline.R \
    $TRIM_DIR \
    $RESULT_DIR \
    $DB_DIR/4_dada2_tax_16S.txt \
    $DB_DIR/4_dada2_sp_16S.txt

echo "Pipeline completed."
