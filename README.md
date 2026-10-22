# eDNA
# Crayfish 16S eDNA pipeline

create a project directory and copy the files within, "crayfish_edna_pipeline" directory to your project directory
  - there should be a, "config" directory with 1 file inside
  - there should be a, "scripts" directory with 7 files inside

open the config file and edit the config file to match your project directory name and make sure all paths match
  - change crayfish_edna_pipeline to match your project directory name (the directory that contains the config and scripts directories)
  
# May need to install conda and CRABS first, if so follow these steps:
  - To download conda:

    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    
  - To install conda (or with the -u it updates conda)
    
    bash Miniconda3-latest-Linux-x86_64.sh -u
    
  - To install CRABS with conda
    
    unset PYTHONPATH
    
    conda create -n CRABS -c conda-forge -c bioconda python=3.10 crabs
    
    activate
    
    conda activate CRABS
    
  - Test crabs
    
    crabs -h

# To execute the pipeline:
  
  cd <path_to_project_directory>
  
  bash scripts/run_pipeline.sh
  
  - to check your jobs as they are running
  
    squeue -u $USER
