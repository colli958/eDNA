# eDNA
Crayfish 16S eDNA pipeline

- Begin with 1_CRABS.sh to build the databasee
  
  - May need to install conda and CRABS first, if so follow these steps:
    
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  - This installs or with the -u it updates conda
    
    bash Miniconda3-latest-Linux-x86_64.sh -u
  - To install CRABS with conda
    
    unset PYTHONPATH
    conda create -n CRABS -c conda-forge -c bioconda python=3.10 crabs
    activate
    conda activate CRABS
  - Test crabs
    
    crabs -h


- Then run 2_cutadapt.sh to trim the metabarcoding fastqs
- Then run 3_dada.sh to assign the samples to taxonomic groups
