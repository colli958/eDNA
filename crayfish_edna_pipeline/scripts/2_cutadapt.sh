#==================================================================================================
#   File: cutadapt_script.sb
#   Date: September 17, 2026
#   Description: Use cutadapt to trim reads and quality filter
#--------------------------------------------------------------------------------------------------
#	Authors: Jared Homola and Erin Collins
#==================================================================================================

# cd raw_seqs
# gunzip *.gz

#update the path to your run directory
# bash 2_cutadapt_script.sh, to run the script
RUN_PATH=/mnt/home/colli958/eDNA_test2/

mkdir -p $RUN_PATH/trimmed
mkdir -p $RUN_PATH/out
mkdir -p $RUN_PATH/qstat/trimQualityFilter
mkdir -p $RUN_PATH/shell/trimQualityFilter

cd $RUN_PATH/shell/trimQualityFilter

module purge
module load cutadapt/4.4-GCCcore-12.2.0

#adjust the path here too the raw_seqs directory
ls $RUN_PATH/raw_seqs/2017_Crayfish_16S/seqs/ | grep "_R1_001.fastq$" | \
sed 's/_R1_001.fastq//' | \
sort | while read -r SAMPLE
do

cat > trimQualityFilter.${SAMPLE}.sh << EOF
#!/bin/bash --login
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=15:00
#SBATCH -J ${SAMPLE}.trim
#SBATCH -o $RUN_PATH/qstat/trimQualityFilter/${SAMPLE}.out

module purge
module load cutadapt/4.4-GCCcore-12.2.0

#update the path to your run directory
cd $RUN_PATH/raw_seqs/2017_Crayfish_16S/seqs/

cutadapt \
    --nextseq-trim=35 \
    -q 25 \
    --minimum-length=10 \
    --cores=4 \
    -o $RUN_PATH/trimmed/${SAMPLE}_trimmed_R1.fastq.gz \
    -p $RUN_PATH/trimmed/${SAMPLE}_trimmed_R2.fastq.gz \
    ${SAMPLE}_R1_001.fastq \
    ${SAMPLE}_R2_001.fastq

EOF

sbatch trimQualityFilter.${SAMPLE}.sh

done