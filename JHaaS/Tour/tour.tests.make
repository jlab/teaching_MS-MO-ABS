SHELL=/usr/bin/bash
DATA=/Data

all: test_datascience test_mafft test_hmmer test_fasttree test_cdhit test_mash test_prodigal test_diamond test_vienna test_infernal

test_datascience:
	@jupyter nbconvert --to python ${DATA}/Tour/bioinf_software.ipynb --stdout > ~/bioinf_software.py
	@ipython bioinf_software.py

test_mafft:
	cat $(DATA)/Tour/meiers.txt
	mafft $(DATA)/Tour/meiers.txt
	mafft $(DATA)/Tour/meiers.fasta

test_hmmer:
	hmmbuild meiers.hmm $(DATA)/Tour/meiers.msa
	cat meiers.hmm
	hmmsearch meiers.hmm $(DATA)/Tour/meierhistory.txt

test_fasttree:
	fasttree $(DATA)/Tour/meiers.msa
	mafft <(for l in `cat $(DATA)/Tour/meiers.fasta | grep -v "^>"`; do echo ">$$l"; echo $$l; done) 2> /dev/null | fasttree

test_cdhit:
	cdhit -i $(DATA)/Tour/meiers.fasta -o clusters_meiers
	cat clusters_meiers
	cat clusters_meiers.clstr
	cdhit -i $(DATA)/Tour/meiers.fasta -o clusters_meiers -l 4 -c 0.6 -n 3
	for l in `cat $(DATA)/Tour/meiers.fasta | grep -v "^>"`; do echo ">$$l"; echo $$l; done > tmp &&  cdhit -i tmp -o clusters_meiers -l 4 -c 0.6 -n 3

test_mash:
	split -l 2 $(DATA)/Tour/meiers.fasta sm_
	mash dist sm_* -k 1
	mash dist $(DATA)/Tour/NC_*.gz | cut -f 2- | column -t
	mash dist $(DATA)/Tour/NC_*.gz -k 15 | cut -f 2- | column -t

test_prodigal:
	zcat $(DATA)/Tour/NC_000913.3*.gz | prodigal | grep "     CDS         " -c

test_diamond:
	zcat $(DATA)/Tour/NC_000913.3*.gz | prodigal -a ecoli.fasta > /dev/null
	zcat $(DATA)/Tour/NC_003210.1*.gz | prodigal -a listeria.fasta > /dev/null
	head ecoli.fasta
	diamond makedb -d ecoli --in ecoli.fasta
	diamond blastp --db ecoli -q listeria.fasta | cut -f 1 | sort | uniq -c | sort -n | tail -n 20
	diamond blastp --max-target-seqs 1 --db ecoli -q listeria.fasta | wc -l
	grep "^>" -c ecoli.fasta listeria.fasta

test_spades:
	spades.py -s $(DATA)/Tour/ass_reads_50-30.fq.gz -o myassembly
	cat myassembly/contigs.fasta
	mafft <(cat $(DATA)/Tour/sarscov2_spike_pcr.fasta myassembly/contigs.fasta) 2> /dev/null
	spades.py -s $(DATA)/Tour/ass_reads_50-60.fq.gz -o myassembly_60
	mafft <(cat $(DATA)/Tour/sarscov2_spike_pcr.fasta myassembly_60/contigs.fasta) 2> /dev/null

test_vienna:
	cat $(DATA)/Tour/trna.fasta | RNAfold
	cat $(DATA)/Tour/mrna.fasta $(DATA)/Tour/hsa-mir-145.fasta | RNAduplex
	
test_infernal:
	wget "https://rfam.org/family/RF00675/alignment?acc=RF00675&format=stockholm&download=0" -O mir145.stk
	cmbuild -F mir145.cm mir145.stk
	cmalign mir145.cm $(DATA)/Tour/hg38_chr5_rnahit.fasta
	cmalign -g mir145.cm $(DATA)/Tour/hg38_chr5_rnahit.fasta