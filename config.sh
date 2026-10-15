#!/bin/bash

# Project directory
PROJECT_DIR="/mnt/home/colli958/eDNA_test2"

# Sequencing files
RAW_DIR="$PROJECT_DIR/raw_seqs/2017_Crayfish_16S/seqs"

# Reference database
DB_DIR="$PROJECT_DIR/reference_db"

# Results
TRIM_DIR="$PROJECT_DIR/trimmed"
RESULT_DIR="$PROJECT_DIR/results"
PLOT_DIR="$PROJECT_DIR/plots"
LOG_DIR="$PROJECT_DIR/logs"

# CRABS settings
EMAIL="colli958@msu.edu"

FORWARD_PRIMER="GGGACGATAAGACCCTAT"
REVERSE_PRIMER="CGCTGTTATCCCTAAAGTAAC"

THREADS=4