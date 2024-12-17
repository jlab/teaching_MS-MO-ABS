SHELL=/usr/bin/bash
DATA=/Data

all: test_model_plot test_homer

test_macs2:
	macs2 callpeak -t ${DATA}/ChIPseq/p65_ChIP-seq_TNF_1_hisat2_unspliced.sorted.bam -c ${DATA}/ChIPseq/p65_Input_TNF_hisat2_unspliced.sorted.bam -n p65_fore-vs-back --outdir ~/callpeak -f BAM -B -g hs
	
test_model_plot: test_macs2
	cat ~/callpeak/p65_fore-vs-back_model.r | R --vanilla
	
test_homer:
	findMotifsGenome.pl ${DATA}/ChIPseq/peakinspection/p65_TNF-top500_intersect.bed hg19 kurt -mask -preparsedDir ./homerPreparsed -S 2 -norevopp -nomotif -basic -nocheck -noknown -noweight -N 500