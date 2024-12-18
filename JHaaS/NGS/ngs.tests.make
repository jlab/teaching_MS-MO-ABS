SHELL=/usr/bin/bash
DATA=/Data
THREADS=2

all: test_ngs_fastqc test_ngs_fmindex SRR3923550_head.sam test_ngs_samtools test_ngs_sra test_blast
test_ngs_fastqc:
	bzcat $(DATA)/NGS/SRR3923550_1.fastq.bz2 | head -n 400 > tmp.fastq
	fastqc tmp.fastq

test_ngs_fmindex:
	# we here use chr21 instead of the chr9 as in the exercises to keep compute a bit lower
	@wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr21.fa.gz -O chr21.fa.gz
	@gunzip -f chr21.fa.gz
	@bowtie2-build --threads ${THREADS} chr21.fa hg19_chr21

#test_ngs_map: test_ngs_fmindex
SRR3923550_head.sam:
	@bzcat $(DATA)/NGS/SRR3923550_1.fastq.bz2 | head -n 4000 | bzip2 -k -9 -c > tmp_1.fastq.bz2
	@bzcat $(DATA)/NGS/SRR3923550_2.fastq.bz2 | head -n 4000 | bzip2 -k -9 -c > tmp_2.fastq.bz2
	@bowtie2 -x $(DATA)/NGS/bowtie-hg19/hg19 -1 tmp_1.fastq.bz2 -2 tmp_2.fastq.bz2 -S SRR3923550_head.sam -p ${THREADS}

test_ngs_samtools: SRR3923550_head.sam
	@samtools view -bh SRR3923550_head.sam -o SRR3923550.bam
	@samtools sort SRR3923550.bam -o SRR3923550_sorted.bam
	@samtools index SRR3923550_sorted.bam
	@echo -e ">chr21\nAUCGAUCGU" > chr9.fa
	@samtools mpileup SRR3923550_sorted.bam
	@bcftools mpileup --no-reference SRR3923550_sorted.bam

test_ngs_sra:
	@fasterq-dump -p ERR12342748
	@cat ERR12342748.fastq | bzip2 -k --fast -c > ERR12342748.fastq.bz2

test_blast:
	@cat ${DATA}/NGS/FASTA1.fasta ${DATA}/NGS/Fasta2.fa  ${DATA}/NGS/Fasta3.fa > all.fasta
	@grep -c "^>" all.fasta
	@makeblastdb -in /Data/NGS/DB1.fasta -parse_seqids -dbtype prot -out myprot
	@makeblastdb -in /Data/NGS/DB2.fasta -dbtype nucl -out mynuc
	@blastx -query all.fasta -db myprot -out all.fasta_vs_DB1_protein_tab.blast -outfmt 6
	@blastx -query all.fasta -db myprot -out all.fasta_vs_DB1_protein_default.blast
	@blastn -query all.fasta -db mynuc -out all.fasta_vs_DB2_nucleotide_tab.blast -outfmt 6
	@blastn -query all.fasta -db mynuc -out all.fasta_vs_DB2_nucleotide_default.blast
	@blastn -query all.fasta -db mynuc -outfmt "6 std sstrand"
