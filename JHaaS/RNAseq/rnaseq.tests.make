SHELL=/usr/bin/bash
DATA=/Data

all: test_normalization_notebook test_rnaseq_trimgalore splicesites out.sam test_rnaseq_featurecounts

test_normalization_notebook:
	@jupyter nbconvert --to python ${DATA}/RNAseq/rnaseq_normalizations.ipynb --stdout > ~/rnaseq_normalizations.py
	@ipython ~/rnaseq_normalizations.py

test_rnaseq_multiqc:
	@zcat ${DATA}/RNAseq/RNA_Scr_T1.fastq.gz | head -n 4000 > ~/srct1.fastq
	@fastqc ~/srct1.fastq
	@multiqc ~/

test_rnaseq_trimgalore:
	@zcat ${DATA}/RNAseq/RNA_Scr_T1.fastq.gz | head -n 4000 > ~/srct1.fastq
	@trim_galore --fastqc -o ~/trimmed/ -j 2 ~/srct1.fastq

splicesites:
	@extract_splice_sites.py <(zcat ${DATA}/Unix/hg19.ncbiRefSeq.gtf.gz) > splicesites
	@wc splicesites

out.sam: splicesites
	@zcat ${DATA}/RNAseq/RNA_Scr_T1.fastq.gz | head -n 400 > ~/srct1.fastq
	@hisat2 -x ${DATA}/RNAseq/hg19/genome --known-splicesite-infile splicesites -p 2 -q -U ~/srct1.fastq -S out.sam

test_rnaseq_featurecounts: out.sam
	@samtools view -bh out.sam | samtools sort -o out.bam
	@samtools index out.bam
	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.gtf.gz > annot
	@featureCounts -a annot -M -O -T 2 -o featureCounts.tsv out.bam