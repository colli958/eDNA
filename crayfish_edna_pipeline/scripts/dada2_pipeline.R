library(dada2)
library(Biostrings)
library(ShortRead)

cat("Starting DADA2 pipeline\n")

input.path <- Sys.getenv("TRIM_DIR")
output.path <- Sys.getenv("DADA2_DIR")
plots.path <- Sys.getenv("PLOT_DIR")

cat("Input directory:", input.path, "\n")
cat("Output directory:", output.path, "\n")
cat("Plot directory:", plots.path, "\n")

reference.db <- Sys.getenv("REFERENCE_DB")
species.file <- Sys.getenv("SPECIES_FILE")

# sort the reads by forward and reverse
# update by changing the pattern to match your trimmed reads
fnFs <- sort(list.files(input.path, pattern = "_trimmed_R1.fastq.gz$", full.names = TRUE))
fnRs <- sort(list.files(input.path, pattern = "_trimmed_R2.fastq.gz$", full.names = TRUE))

cat("Forward files found:", length(fnFs), "\n")
cat("Reverse files found:", length(fnRs), "\n")

if(length(fnFs) == 0 || length(fnRs) == 0) {
    stop("No trimmed FASTQ files found.")
}

# dada2 quality control options. plots read length by quality
# Extract sample names
get.sample.name <- function(fname) strsplit(basename(fname), "_")[[1]][2]
sample.names <- unname(sapply(fnFs, get.sample.name))

# check the quality for the first file forward reads
png(file.path(plots.path, "sample1F_qual_plot.png"), width=1200, height=800, type="cairo")
plotQualityProfile(fnFs[1:1])
dev.off()
# check the quality for the first file reverses
png(file.path(plots.path, "sample1R_qual_plot.png"), width=1200, height=800, type="cairo")
plotQualityProfile(fnRs[1:1])
dev.off()

# to check these plots, download the files in the /mnt/home/colli958/eDNA_test/plots/ directory
#To interpret the plots, the gray-scale heatmap shows the the frequency of each quality score along the forward read lengths. The green line is the median quality score and the orange lines are the quartiles. The red line at the bottom of the plot represents the proportion of reads of that particular length. The quality is very good for our forward reads. You can also see that the majority of the forward reads are ~130bp long as the primers sequences were removed with cutadapt.

cat("Starting filterAndTrim\n")

# filter the data
# path to directory of filtered output files
filtFs <- file.path(output.path, "filtered", basename(fnFs))
filtRs <- file.path(output.path, "filtered", basename(fnRs))

# maxN=0 After truncation, sequences with more than 0 Ns will be discarded. (DADA2 requires sequences contain no Ns)
# truncQ = 2 Truncate reads at the first instance of a quality score less than or equal to 2
# rm.phix = TRUE Discard reads that match against the phiX genome
# maxEE=c(2, 2) After truncation, reads with higher than 2 "expected errors" will be discarded
# minLen = 60 Remove reads with length less than 60
# multithread = TRUE input files are filtered in parallel
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, maxN = 0, maxEE = c(2, 2),
                     truncQ = 2, minLen = 60, rm.phix = TRUE, compress = TRUE,
                     multithread = TRUE)
out

cat("Finished filterAndTrim\n")

cat("Learning error models\n")

# identify the ASVs (Amplicon Sequence Variants)
# 1. Generate an error model
errF <- learnErrors(filtFs, multithread = TRUE)
errR <- learnErrors(filtRs, multithread = TRUE)
# update this path
png(file.path(plots.path, "error_model.png"), width = 1200, height = 800, type = "cairo")
plotErrors(errF, nominalQ = TRUE)
dev.off()

# don't worry about error messages
# To interpret the plots:
# The error rates for each possible transition (e.g. A→C, A→G) are shown
# Red line - expected based on the quality score. (These are plotted when nominalQ = TRUE is included in the plot command)
# Black line - estimate
# Black dots - observed
# What we are expecting to see here is that the observed match up with estimates. Here we can see that the black dots track well with the black line. We can also see that the error rates drop with increasing quality score as we would expect. Sanity checks complete, we can proceed with the analysis.
# If you are worried about what your error plots look like when you fit your own dataset, one possible way to to improve the fit is to try increasing the number of bases the function is using (the default is 100 million).

cat("Starting dereplication\n")
# 2. Dereplicate identical reads. No longer running multiple of identical sequences, but keeps data about how many there were.
exists <- file.exists(filtFs)
# check that all the samples are still present after filtering
derepFs <- derepFastq(filtFs[exists], verbose=TRUE)
derepRs <- derepFastq(filtRs[exists], verbose=TRUE)
# Name the derep-class objects by the sample names
names(derepFs) <- sample.names[exists]
names(derepRs) <- sample.names[exists]

# 3. Inference of ASVs
# DADA2 uses the error models created above to infer the true sample composition.
dadaFs <- dada(derepFs, err = errF, multithread = TRUE)
dadaRs <- dada(derepRs, err = errR, multithread = TRUE)

# 4. Merging paired-end reads
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)

# 5. Make the ASV matrix
# Each column represents a single ASV and each row is an individual sample.
seqtab <- makeSequenceTable(mergers)
# shows the number of total ASVs
dim(seqtab)

# 6. Chimera detection and removal
# Chimeric sequences are formed when two or more biological sequences are joined together. This is fairly common in amplicon sequencing. DADA2 uses a method whereby it combines the left and right segments of abundant reads and compares these with lower abundant sequences. Any low abundant sequences that match are removed.
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus",
                                    multithread=TRUE, verbose=TRUE)

dim(seqtab.nochim)
# Most ASVs have been identified as chimeric. Although this is a large proportion of sequence variants it should be a smaller proportion of the total sequences.
# check the proportion of sequences in the matrix with chimeras removed versus the original matrix. This number shows the remaining percentage of sequences:
sum(seqtab.nochim)/sum(seqtab)
# check the range of sequence lengths:
# reads like a histogram, lengths in first row, number of sequences that length in the second row
table(nchar(getSequences(seqtab.nochim)))

# 7. Sequence number tracking after each filtering step as a sanity check
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN),
               sapply(dadaRs, getN),
               sapply(mergers, getN),
               rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered",
                     "denoisedF", "denoisedR",
                     "merged", "nonchim")
rownames(track) <- sample.names
track

cat("Starting taxonomy assignment\n")
# assign taxonomy
# assignments based on reference database fasta included in the download
taxa <- assignTaxonomy(seqtab.nochim, reference.db, multithread=TRUE, verbose=TRUE)

taxa.print <- taxa
rownames(taxa.print) <- NULL
head(taxa.print)

write.csv(seqtab.nochim, file.path(output.path, "ASV_table.csv"))
write.csv(taxa, file.path(output.path, "taxonomy_assignments.csv"))
write.csv(track, file.path(output.path, "read_tracking.csv"))
saveRDS(seqtab.nochim, file.path(output.path, "seqtab_nochim.rds"))
saveRDS(taxa, file.path(output.path, "taxonomy.rds"))

cat("DADA2 pipeline complete\n")