SHELL=/usr/bin/bash
DATA=/Data

all: test_python_intro

test_python_intro:
	@jupyter nbconvert --to python ${DATA}/Python/python_intro.ipynb --stdout > ~/python_intro.py
	@mkdir -p ~/data
	@ln -s -f ${DATA}/Tour/meiers.txt ~/data/meiers.txt 
	@ln -s -f ${DATA}/Tour/meiers.fasta ~/data/meiers.fasta 
	@ln -s -f ${DATA}/Python/MolecularWeight_tair7.tsv ~/data/MolecularWeight_tair7.tsv 
	@ln -s -f ${DATA}/Python/TargetP_analysis_tair7.tsv ~/data/TargetP_analysis_tair7.tsv 
	@ipython ~/python_intro.py
