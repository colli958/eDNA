source ../config/config.sh

mkdir -p $DB_DIR

crabs --download-ncbi \
  --query '(Cambaridae[Organism] OR "Pacifastacus leniusculus"[Organism] OR Cherax[Organism]) AND (16S[All Fields] OR "large subunit ribosomal RNA gene"[All Fields])' \
  --output $DB_DIR/16S.fasta \
  --email $EMAIL \
  --database nucleotide