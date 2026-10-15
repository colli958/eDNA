# install conda
# curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# this installs or with the -u it updates conda
# bash Miniconda3-latest-Linux-x86_64.sh -u

# to install CRABS with conda
# unset PYTHONPATH
# conda create -n CRABS -c conda-forge -c bioconda python=3.10 crabs
# activate
# conda activate CRABS
# test crabs
# crabs -h

# useful conda commands
###############################
# to see all installed packages
conda list
# to leave current environment
conda deactivate
# to see all environments
conda env list
# to remove an environment
conda remove -n env_to_remove --all
# to rename an environment
conda rename -n old_env_name new_env_name
###############################

# to activate the environment after installation
unset PYTHONPATH
conda activate CRABS
# create a directory to store the downloaded data
OUTDIR="/mnt/home/colli958/crabs_testing"
mkdir -p "$OUTDIR"
# to download 16S data for CRABS
crabs --download-ncbi \
  --query '(Cambaridae[Organism] OR "Pacifastacus leniusculus"[Organism] OR Cherax[Organism]) AND (16S[All Fields] OR "large subunit ribosomal RNA gene"[All Fields])' \
  --output "$OUTDIR/16S.fasta" \
  --email colli958@msu.edu \
  --database nucleotide

# Download NCBI taxonomy files needed for import
crabs --download-taxonomy \
  --output "$OUTDIR"

# import the 16S database
crabs --import \
  --import-format ncbi \
  --input "$OUTDIR/16S.fasta" \
  --names "$OUTDIR/names.dmp" \
  --nodes "$OUTDIR/nodes.dmp" \
  --acc2tax "$OUTDIR/nucl_gb.accession2taxid" \
  --output "$OUTDIR/crabs_format_16S.txt" \
  --ranks 'superkingdom;phylum;class;order;family;genus;species'

# trim to primer regions of 16S
crabs --in-silico-pcr --input $OUTDIR/crabs_format_16S.txt --output $OUTDIR/1_insilico_16S.txt --forward GGGACGATAAGACCCTAT --reverse CGCTGTTATCCCTAAAGTAAC

# remove identical sequences and keep only unique sequences
crabs --dereplicate --input $OUTDIR/1_insilico_16S.txt --output $OUTDIR/2_dereplicated_16S.txt --dereplication-method 'unique_species'

# filter
crabs --filter --input $OUTDIR/2_dereplicated_16S.txt --output $OUTDIR/3_filtered_16S.txt --minimum-length 100 --maximum-length 300 --maximum-n 1 --environmental --no-species-id --rank-na 2

# export in dada2 format for taxonomic assignment
crabs --export --input $OUTDIR/3_filtered_16S.txt --output $OUTDIR/4_dada2_tax_16S.txt --export-format 'dada2-taxonomy'
# export in dada2 format for species assignment
crabs --export --input $OUTDIR/3_filtered_16S.txt --output $OUTDIR/4_dada2_sp_16S.txt --export-format 'dada2-species'