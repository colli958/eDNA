# eDNA
# Crayfish 16S eDNA pipeline

create a directory structure that mimics what is in the config file 

edit the config file as needed

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

- To execute the pipeline:
    bash run_pipeline.sh
