SHELL=/usr/bin/bash
DATA=/Data

all: test_normalization_notebook

test_normalization_notebook:
	@jupyter nbconvert --to python ${DATA}/RNAseq/rnaseq_normalizations.ipynb --stdout > ~/rnaseq_normalizations.py
	@ipython ~/rnaseq_normalizations.py
