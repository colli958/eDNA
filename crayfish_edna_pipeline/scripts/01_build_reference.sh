#!/bin/bash

set -euo pipefail

###############################################################################
# Determine pipeline location
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PIPELINE_DIR="$( dirname "$SCRIPT_DIR" )"

###############################################################################
# Load configuration
###############################################################################

source "${PIPELINE_DIR}/config/config.sh"

###############################################################################
# Activate CRABS environment
###############################################################################

unset PYTHONPATH
source ~/miniconda3/etc/profile.d/conda.sh
conda activate CRABS

###############################################################################
# Create output directory
###############################################################################

OUTDIR="$DB_DIR"
mkdir -p "$OUTDIR"

echo "=================================="
echo "Building CRABS Reference Database"
echo "Database directory: $OUTDIR"
echo "Forward primer: $FORWARD_PRIMER"
echo "Reverse primer: $REVERSE_PRIMER"
echo "=================================="

###############################################################################
# Build NCBI query from species list
###############################################################################

if [[ ! -s "$SPECIES_FILE" ]]; then
    echo "ERROR: Species file not found or empty:"
    echo "  $SPECIES_FILE"
    exit 1
fi

SPECIES_QUERY=$(awk '
{
    gsub(/\r/, "")
    if (length($0) > 0)
        printf "%s\"%s\"[Organism]", (n++ ? " OR " : ""), $0
}' "$SPECIES_FILE")

GENE_QUERY='(
16S[All Fields] OR
"16S rRNA"[All Fields] OR
"16S ribosomal RNA"[All Fields] OR
"16S ribosomal RNA gene"[All Fields] OR
"large subunit ribosomal RNA gene"[All Fields] OR
"mitochondrial 16S"[All Fields] OR
"mitochondrial large subunit rRNA"[All Fields]
)'

QUERY="(${SPECIES_QUERY}) AND ${GENE_QUERY}"

echo "$QUERY" > "$OUTDIR/ncbi_query.txt"

echo "Species loaded: $(wc -l < "$SPECIES_FILE")"
echo "NCBI query saved to:"
echo "  $OUTDIR/ncbi_query.txt"

###############################################################################
# Download target sequences from NCBI
###############################################################################

crabs --download-ncbi \
    --query "$QUERY" \
    --output "$OUTDIR/16S.fasta" \
    --email "$EMAIL" \
    --database nucleotide
    
SEQ_COUNT=$(grep -c "^>" "$OUTDIR/16S.fasta" || true)

echo "Downloaded ${SEQ_COUNT} sequences"


###############################################################################
# Download taxonomy files
###############################################################################

crabs --download-taxonomy \
    --output "$OUTDIR"

###############################################################################
# Import records into CRABS format
###############################################################################

crabs --import \
    --import-format ncbi \
    --input "$OUTDIR/16S.fasta" \
    --names "$OUTDIR/names.dmp" \
    --nodes "$OUTDIR/nodes.dmp" \
    --acc2tax "$OUTDIR/nucl_gb.accession2taxid" \
    --output "$OUTDIR/crabs_format_16S.txt" \
    --ranks 'superkingdom;phylum;class;order;family;genus;species'

###############################################################################
# In silico PCR
###############################################################################

crabs --in-silico-pcr \
    --input "$OUTDIR/crabs_format_16S.txt" \
    --output "$OUTDIR/1_insilico_16S.txt" \
    --forward "$FORWARD_PRIMER" \
    --reverse "$REVERSE_PRIMER"

###############################################################################
# Dereplicate
###############################################################################

crabs --dereplicate \
    --input "$OUTDIR/1_insilico_16S.txt" \
    --output "$OUTDIR/2_dereplicated_16S.txt" \
    --dereplication-method unique_species

###############################################################################
# Filter
###############################################################################

crabs --filter \
    --input "$OUTDIR/2_dereplicated_16S.txt" \
    --output "$OUTDIR/3_filtered_16S.txt" \
    --minimum-length 100 \
    --maximum-length 300 \
    --maximum-n 1 \
    --environmental \
    --no-species-id \
    --rank-na 2
    
cut -f8 "$OUTDIR/3_filtered_16S.txt" | sort -u > "$OUTDIR/species_retained.txt"

wc -l "$SPECIES_FILE"
wc -l "$OUTDIR/species_retained.txt"

###############################################################################
# Export DADA2 taxonomy database
###############################################################################

crabs --export \
    --input "$OUTDIR/3_filtered_16S.txt" \
    --output "$OUTDIR/4_dada2_tax_16S.txt" \
    --export-format dada2-taxonomy

###############################################################################
# Export DADA2 species database
###############################################################################

crabs --export \
    --input "$OUTDIR/3_filtered_16S.txt" \
    --output "$OUTDIR/4_dada2_sp_16S.txt" \
    --export-format dada2-species

echo ""
echo "CRABS database build completed successfully."
echo "Outputs:"
echo "  $OUTDIR/4_dada2_tax_16S.txt"
echo "  $OUTDIR/4_dada2_sp_16S.txt"