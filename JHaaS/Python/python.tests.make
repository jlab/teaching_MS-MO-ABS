SHELL=/usr/bin/bash
DATA=/Data

all: test_python_intro test_exercises

test_python_intro:
	@jupyter nbconvert --to python ${DATA}/Python/python_intro.ipynb --stdout > ~/python_intro.py
	@mkdir -p ~/data
	@ln -s -f ${DATA}/Tour/meiers.txt ~/data/meiers.txt 
	@ln -s -f ${DATA}/Tour/meiers.fasta ~/data/meiers.fasta 
	@ln -s -f ${DATA}/Python/MolecularWeight_tair7.tsv ~/data/MolecularWeight_tair7.tsv 
	@ln -s -f ${DATA}/Python/TargetP_analysis_tair7.tsv ~/data/TargetP_analysis_tair7.tsv 
	@ipython ~/python_intro.py

test_exercises:
	@jupyter nbconvert --to python ${DATA}/Python/Python_solutions.ipynb --stdout > ~/Python_solutions.py
	@sed "s/+ variable_int +/+ str(variable_int) +/" -i ~/Python_solutions.py
	@ipython Python_solutions.py
	@jupyter nbconvert --to python ${DATA}/Python/Pandas_solutions.ipynb --stdout > ~/Pandas_solutions.py
	@ipython Pandas_solutions.py
