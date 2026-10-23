# eDNA
# Crayfish 16S eDNA pipeline

this pipeline is designed to work within Michigan State University's HPCC system

create a project directory in your hpcc drive and copy the files within, "crayfish_edna_pipeline" directory from this GitHub page to your project directory
  - inside your project directory, there should be a, "config" directory with 1 file inside
  - inside your project directory, there should also be a, "scripts" directory with 7 files inside
  - next, create a raw_seqs directory and move your raw fastq data to this directory

open the config file and edit it to match your project directory name and make sure all paths match
  - look for "crayfish_edna_pipeline" and change to match your project directory name (the directory that contains the config and scripts directories)
  
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
  
  - to check your jobs as they are running, look at the log files in the log directory or:
  
    squeue -u $USER
