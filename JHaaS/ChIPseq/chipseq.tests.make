SHELL=/usr/bin/bash
DATA=/Data
SAMTOOLS=/opt/conda/envs/rnaseq/bin/samtools  # requires that the rnaseq environment has been installed first!

all: test_model_plot test_homer test_corrplot

test_macs2:
	macs2 callpeak -t ${DATA}/ChIPseq/p65_ChIP-seq_TNF_1_hisat2_unspliced.sorted.bam -c ${DATA}/ChIPseq/p65_Input_TNF_hisat2_unspliced.sorted.bam -n p65_fore-vs-back --outdir ~/callpeak -f BAM -B -g hs
	
test_model_plot: test_macs2
	cat ~/callpeak/p65_fore-vs-back_model.r | R --vanilla
	
test_homer:
	findMotifsGenome.pl ${DATA}/ChIPseq/homer/p65_TNF-top500_intersect.narrowPeak hg19 kurt -mask -preparsedDir ./homerPreparsed -S 2 -norevopp -nomotif -basic -nocheck -noknown -noweight -N 500

test_corrplot:
	rm -f tmp_tnf1.bam tmp_tnf1.bam.bai
	rm -f tmp_tnf2.bam tmp_tnf2.bam.bai
	rm -f  tmp.npz tmp.pdf
	${SAMTOOLS} view -h ${DATA}/ChIPseq/p65_ChIP-seq_TNF_1_hisat2_unspliced.sorted.bam | head -n 4000 | ${SAMTOOLS} view -b > tmp_tnf1.bam
	${SAMTOOLS} view -h ${DATA}/ChIPseq/p65_ChIP-seq_TNF_2_hisat2_unspliced.sorted.bam | head -n 4000 | ${SAMTOOLS} view -b > tmp_tnf2.bam
	${SAMTOOLS} index tmp_tnf1.bam
	${SAMTOOLS} index tmp_tnf2.bam
	multiBamSummary BED-file --BED ${DATA}/ChIPseq/peakinspection/p65_TNF_Vehicle_consensus.bed --bamfiles tmp_tnf1.bam tmp_tnf2.bam --outFileName tmp.npz
	plotCorrelation --corData tmp.npz --plotFile tmp.pdf --whatToPlot heatmap --corMethod pearson --plotNumbers --removeOutliers
