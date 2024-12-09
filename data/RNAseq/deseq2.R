# Parse arguments
args <- commandArgs(TRUE)
counttable_file <- args[match('--count-table', args) + 1]
condition_file <- args[match('--conditions', args) + 1]
feature_counts_log_file <- args[match('--featcounts-log', args) + 1]
output_folder <- args[match('--output', args) + 1]
output_vis <- paste(output_folder, "visualization", sep = "/")
output_comparison <- paste(output_folder, "deseq2_comparisons", sep = "/")

# Create all DESeq2 comparisons
if (!file.exists(output_comparison)) {
    dir.create(output_comparison)
}
if (!file.exists(output_vis)) {
    dir.create(output_vis)
}

# Required packages
for (package in c("DESeq2", "pheatmap", "ggplot2", "reshape2", "gplots", "svglite")) {
        print(paste("Import:", package))
        library(package, character.only=TRUE)
}


####### FUNCTIONS #######
# Heatmap showing similarities between samples (needs a count table and conditions )
create_correlation_matrix <- function(countdata, conditiontable) {
    countdata.normalized.processed <- as.matrix(countdata)
    countdata.normalized.processed <- countdata.normalized.processed[rowSums(countdata.normalized.processed) >= 10,]
    countdata.normalized.processed <- log2(countdata.normalized.processed + 1)
    sample_cor <- cor(countdata.normalized.processed, method = 'pearson', use = 'pairwise.complete.obs')

    return(pheatmap(sample_cor, annotation_row = conditiontable))
}

# Bar charts showing the assignment of allignments to genes (featureCounts statistics)
create_feature_counts_statistics <- function(featureCountsLog) {
    d <- read.table(featureCountsLog, header = T, row.names = 1)
    colnames(d) <- gsub(".bam", "", colnames(d))

    dpct <- t(t(d) / colSums(d))

    dm <- melt(t(d))
    dpctm <- melt(t(dpct))

    colnames(dm) <- c("Sample", "Group", "Reads")
    dm$Group <- factor(dm$Group, levels = rev(levels(dm$Group)[order(levels(dm$Group))]))

    assignment.absolute <- ggplot(dm[dm$Reads > 0,], aes(x = Sample, y = Reads)) +
        geom_bar(aes(fill = Group), stat = "identity", group = 1) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    colnames(dpctm) <- c("Sample", "Group", "Reads")
    dpctm$Group = factor(dpctm$Group, levels = rev(levels(dpctm$Group)[order(levels(dpctm$Group))]))
    assignment.relative <- ggplot(dpctm[dpctm$Reads > 0,], aes(x = Sample, y = Reads)) +
        geom_bar(aes(fill = Group), stat = "identity", group = 1) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    return(list(assignment.absolute, assignment.relative))
}

rotate_vector <- function(vec, n=1L){
    x <- seq(1, length(vec))
    while (n > 0) {
        x <- c(x[2 : length(x)], x[1])
        n <- n - 1
    }
    vec[x]
}
####### FUNCTIONS END #######

# Import count table (featureCounts)
countdata.raw <- read.csv(counttable_file, header = TRUE, row.names = 1, sep = "\t", comment.char = "#")
countdata <- as.matrix(countdata.raw[, c(6 : length(countdata.raw))])
# removes 'mapping/' and '.bam' from sample name. Works only if bam files are in mapping folder
colnames(countdata) <- as.vector(sapply(colnames(countdata), function(x) gsub("mapping\\.(.*)\\.bam", "\\1", x)))

# Import condition file:
#
# Sample1<tab>Condition1
# Sample2<tab>Condition1
# Sample3<tab>Condition2
# Sample4<tab>Condition2
#
conditiontable <- read.csv(condition_file, header = FALSE, row.names = 1, sep = "\t", comment.char = "#")
rownames(conditiontable) <- gsub("-", ".", rownames(conditiontable))
colnames(conditiontable) <- c('condition')
conditiontable$condition <- factor(conditiontable$condition, levels = unique(conditiontable$condition))
condition <- as.factor(conditiontable$condition)

deseqDataset <- DESeqDataSetFromMatrix(countData = countdata, colData = conditiontable, design = ~ condition)

# Write normalized count table
deseqDataset <- estimateSizeFactors(deseqDataset)
countdata.normalized <- counts(deseqDataset, normalized = TRUE)
write.table(data.frame("geneid"=rownames(countdata.normalized),countdata.normalized, check.names=FALSE), file = paste(output_folder, "/", "counts_deseq2_normalized.tsv", sep = ""), sep = "\t", row.names = FALSE)

# Often called dds
deseq.results <- DESeq(object = deseqDataset, parallel = FALSE)

# Heatmap showing similarities between samples (needs a count table and conditions )
if ("pheatmap" %in% rownames(installed.packages())) {
    svglite(paste(output_vis, 'correlation_heatmap.svg', sep = "/"))
    print(create_correlation_matrix(countdata.normalized, conditiontable))
    dev.off()
}

# Bar charts showing the assignment of allignments to genes (featureCounts statistics)
if (("ggplot2" %in% rownames(installed.packages())) && ("reshape2" %in% rownames(installed.packages())) && ("svglite" %in% rownames(installed.packages()))) {
    plots <- create_feature_counts_statistics(feature_counts_log_file)
    svglite(paste(output_vis, 'counts_assignment_absolute.svg', sep = "/"))
    print(plots[1])
    dev.off()
    svglite(paste(output_vis, 'counts_assignment_relative.svg', sep = "/"))
    print(plots[2])
    dev.off()
}

# PCA of DESeq2 data (needs a DESeq2 dataset )
{
    rld <- rlog(deseqDataset)
    svglite(paste(output_vis, 'pca.svg', sep = "/"))
    print(plotPCA(rld))
    dev.off()
}

for (cond in combn(levels(condition), 2, simplify = FALSE)) {
    res <-
    results(deseq.results,
    addMLE = FALSE,
    contrast = c("condition", cond[1], cond[2]))
    write.table(res, file = paste(output_comparison, "/", "deseq2_results_", cond[1], "_Vs_", cond[2], ".csv", sep = ""), sep = "\t", row.names = TRUE, col.names = NA)
}
