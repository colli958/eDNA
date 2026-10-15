#!/bin/bash
#SBATCH --array=1-100
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

module purge
module load cutadapt/4.4-GCCcore-12.2.0

source config.sh

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" sample_list.txt)

cutadapt \
   --nextseq-trim=35 \
   -q 25 \
   --minimum-length=10 \
   --cores=4 \
   -o ${TRIM_DIR}/${SAMPLE}_trimmed_R1.fastq.gz \
   -p ${TRIM_DIR}/${SAMPLE}_trimmed_R2.fastq.gz \
   ${RAW_DIR}/${SAMPLE}_R1_001.fastq \
   ${RAW_DIR}/${SAMPLE}_R2_001.fastq