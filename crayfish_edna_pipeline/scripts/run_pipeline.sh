#!/bin/bash --login

set -e

source config/config.sh

echo "======================================="
echo             "eDNA Pipeline"
echo "======================================="

###############################################################################
# Step 1: Build reference database if needed
###############################################################################

if [ -f "$REFERENCE_DB" ]; then
    echo
    echo "[1/4] Reference database found."
    echo "Skipping CRABS database build."
else
    echo
    echo "[1/4] Building reference database..."
    bash scripts/01_build_reference.sh
fi

###############################################################################
# Step 2: Create sample list
###############################################################################

echo
echo "[2/4] Generating sample list..."

bash scripts/00_make_samplelist.sh

###############################################################################
# Step 3: Run cutadapt
###############################################################################

echo
echo "[3/4] Submitting cutadapt job..."

CUTADAPT_JOB=$(bash scripts/02_trim_reads.sh)

if [[ "$CUTADAPT_JOB" =~ ^[0-9]+$ ]]; then
    echo "[4/4] Submitting DADA2 job..."

    sbatch \
        --export=ALL,PIPELINE_DIR="$PROJECT_DIR" \
        --dependency=afterok:${CUTADAPT_JOB} \
        --output="$DADA2_LOG_DIR/dada2_%j.out" \
        --error="$DADA2_LOG_DIR/dada2_%j.err" \
        scripts/03_run_dada.sb

else
    echo "Cutadapt already completed. [4/4] Submitting DADA2 immediately."

    sbatch \
        --export=ALL,PIPELINE_DIR="$PROJECT_DIR" \
        --output="$DADA2_LOG_DIR/dada2_%j.out" \
        --error="$DADA2_LOG_DIR/dada2_%j.err" \
        scripts/03_run_dada.sb
fi

echo
echo "Pipeline submitted successfully."