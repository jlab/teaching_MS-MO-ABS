SHELL=/usr/bin/bash
DATA=/Data

all: test_ex_unix_basic1 test_ex_unix_basic2 test_ex_unix_basic3 test_ex_unix_basic4 test_ex_unix_level2 test_ex_unix_fileformats test_lecture_unix test_unix_scripts test_lecture_regex test_lecture_awk test_exercise_sed test_bioinfformats_hpylori
test_ex_unix_basic1:
	@echo "hello world"
	@date
	@whoami
	@which -a top
	@echo {con,pre}{sent,fer}{s,ed}
	@which -a man
	@which -a bc
	@echo 5+4 | bc -l
	@time sleep 1
	@cal 2020
	@cal 9 1752
	#history  # a bash feature, not a command

test_ex_unix_basic2:
	@pwd
	@which -a ls
	@mkdir 'Exercise 1'
	@mv 'Exercise 1' Exercise_1
	@which -a rmdir
	@which -a mv

test_ex_unix_basic3:
	@touch catcontent.txt
	@cat catcontent.txt
	@touch .invisible_kitten
	@echo "inhalt" > .invisible_kitten
	@which -a more
	@which -a cp

test_ex_unix_basic4:
	@which -a readlink
	@which -a head
	@which -a tail
	@which -a nano
	@which -a rm
	@which -a groups

test_ex_unix_level2:
	# exercise: Linux Level 2, 1-4
	@mkdir -p www www/html www/java temp junk
	@touch junk/useless
	@cp junk/useless temp/
	@mv temp/useless ~/ && mv junk/useless ~/othername
	@rm useless othername

	# exercise: Linux Level 2, 5
	@cd junk && touch useless && chmod g+rw useless && chmod u+rwx useless && chmod o-rwx useless
	@chgrp biologists junk/useless

	# exercise: Linux Level 2, 6
	@touch junk/shared.txt && chgrp biologists junk/shared.txt

	# exercise: Linux Level 2, 7
	@rm -rf www www/html www/java temp junk

	# exercise: Linux Level 2, 8
	@touch -- '-r' && rm -- '-r'

	# exercise: Linux Level 2, 9
	@head -n 3 ${DATA}/Unix/students.txt
	@tail -n 12 ${DATA}/Unix/students.txt

test_ex_unix_fileformats:
	# exercise: Linux - Bioinformatics file Formats
	@ls -lah ${DATA}/Unix/hg19*
	@wc ${DATA}/Unix/hg19*
	@zcat ${DATA}/Unix/hg19*.fasta.gz | grep "^>" -c
	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.gtf.gz | grep `zcat ${DATA}/Unix/hg19.ncbiRefSeq.chr1.mapping.txt.gz | grep "RPS8" | cut -f 1` | grep exon -c

	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.chr1.mapping.txt.gz | tail -n +2 | cut -f 2 | sort -u | wc -l
	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.chr1.mapping.txt.gz | tail -n +2 | sort -k2,2 | awk '{print $2}' | uniq | wc -l
	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.chr1.mapping.txt.gz | tail -n +2 | awk '{print $2}' | sort | uniq | wc -l

	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.chr1.fasta.gz | sed -n '/NM_001012.1/,/>/p' | head -n -1
	@zcat ${DATA}/Unix/hg19.ncbiRefSeq.chr1.fasta.gz | awk 'BEGIN{RS=">";FS="\n"}NR>1 {if ($$1~/NM_001012.1/)print ">"$$0}'

	@which -a sort
	@which -a uniq
	@which -a grep

test_lecture_unix:
	# lecture "Unix Basics"
	@touch testFile.txt
	@export PS1="\u@\h:\w :-)  "
	@mv testFile.txt foo.txt
	@cp foo.txt barcopy.txt
	@rm foo.txt
	@touch baz.txt
	@cp barcopy.txt .hidden.txt
	@rm .hidden.txt barcopy.txt baz.txt
	@mkdir -p tuser/Mail tuser/thesis/{pictures,literature}
	@touch tuser/baz.txt tuser/Mail/hello.txt tuser/thesis/literature/{1,2,3}.pdf tuser/thesis/Abstract.txt
	@ps -u ${NB_USER}

	@cat ${DATA}/Unix/users.txt
	@head -2 ${DATA}/Unix/users.txt
	@tail -1 ${DATA}/Unix/users.txt
	@echo "Hello World"
	@sort ${DATA}/Unix/users.txt
	@wc -l ${DATA}/Unix/users.txt
	@grep User ${DATA}/Unix/users.txt
	@cat ${DATA}/Unix/awk.txt | cut -f 1 | cut -b 6-
	@ps -ef > ps.txt && head -3 ps.txt
	@sort < ${DATA}/Unix/users.txt
	@cat ${DATA}/Unix/users.txt | sort
	@ps -f -u `whoami`
	@find ${NB_HOME} -name users.txt
	@basename /homes/juser/foo.jpg
	@dirname /homes/juser/foo.jpg
	@touch ~/foo.jpg && readlink -f ~/foo.jpg

	@wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr21.fa.gz
	@gunzip chr21.fa.gz
	@tail -n 2000 chr21.fa | head -n 15 > chr21subset.fa; true  # see https://stackoverflow.com/questions/19120263/why-exit-code-141-with-grep-q
	@cat chr21subset.fa | grep "atg"
	@cat chr21subset.fa | sed s/atg/ATG/g
	@cat chr21subset.fa | tr -d "\n" | sed s/atg/ATG/g | fold -w 50

test_unix_scripts:
	@rm -rf Backup && touch kurt && ${DATA}/Unix/script_backup_copy.sh kurt && test -f Backup/kurt_*
	@rm -rf Backup && touch kurt && ${DATA}/Unix/script_backup_copy.sh kurt > log && grep -c "newly created" log
	@touch kurt && ${DATA}/Unix/script_backup_copy.sh kurt > log && grep -c "already exists" log
	@${DATA}/Unix/script_backup_copy.sh kurt_no > log && grep -c "does not exist" log
	@${DATA}/Unix/script_compare_numbers.sh 1 2 | grep "is smaller than"
	@${DATA}/Unix/script_compare_numbers.sh 2 2 | grep "is equal to"
	@${DATA}/Unix/script_compare_numbers.sh 2 1 | grep "is greater than"
	@${DATA}/Unix/script_compare_numbers.sh 2 a | grep "this is wired"

TEST_PRINT=$(shell sed 's/Faust/Rüdiger/p' ${DATA}/Unix/faust.txt | wc -l)
TEST_SUPRESS=$(shell sed -n 's/Faust/Rüdiger/p' ${DATA}/Unix/faust.txt | wc -l)
test_lecture_regex:
	@echo "a aegtetgeg eg e" | grep "eg"
	@echo "a aegtetgeg eg e" | grep "eg."
	@echo "a aegtetgeg eg e" | grep "eg*"
	@echo "a aegtetgeg eg e" | grep ".*"
	@echo "a aegtetgeg eg e" | grep "[a-f]"
	@sed 's/Faust/Rüdiger/g' ${DATA}/Unix/faust.txt | grep Rüdiger
	@sed '/^H/ s/Faust/Rüdiger/g' ${DATA}/Unix/faust.txt | grep -E "Rüdiger|Faust"
	@sed '/^H/,/^J/ s/Faust/Rüdiger/g' ${DATA}/Unix/faust.txt | grep -E "Rüdiger|Faust"
	@test ${TEST_PRINT} -eq 9
	@test ${TEST_SUPRESS} -eq 3

TEST_COL1=$(shell awk '{print $$1}' ${DATA}/Unix/awk.txt | wc -m)
TEST_COL1_2=$(shell cat ${DATA}/Unix/awk.txt | awk '{print $$1}' | wc -m)
TEST_ALL=$(shell awk '{print $$0}' ${DATA}/Unix/awk.txt | wc -m)
TEST_COL1_minus2=$(shell cat ${DATA}/Unix/awk.txt | awk '{print $$1, $$(NF-2)}' | wc -m)
test_lecture_awk:
	@test ${TEST_COL1} -eq 42
	@test ${TEST_COL1_2} -eq 42
	@test ${TEST_ALL} -eq 121
	@echo "this is a test" | awk '{print $$3}' | grep "^a$$"
	@echo "this is a test" | awk '{print $$NF}' | grep "^test$$"
	@test ${TEST_COL1_minus2} -eq 52
	@cat ${DATA}/Unix/awk.txt | awk '{print $$1,$$3}' | grep "nucleotide_motif"
	@cat ${DATA}/Unix/awk.txt | awk 'BEGIN{FS="_"} {print $$1,$$3}' | grep "fimo\."
	@cat ${DATA}/Unix/awk.txt | awk '{print $$1}' | awk 'BEGIN{FS="_"} {print $$1,$$3}' | grep -v "fimo\."

test_exercise_sed:
	@cat ${DATA}/Unix/students.txt | sed -n '2p'
	@cat ${DATA}/Unix/students.txt | sed -n '2,5p'
	@cat ${DATA}/Unix/students.txt | sed -n '/^M/p'
	@cat ${DATA}/Unix/students.txt | sed '/^M/d'
	@cat ${DATA}/Unix/students.txt | sed 's/[1-9]/2/g'
	@cat ${DATA}/Unix/students.txt | sed 's/Mateo/Unbekannt/g'
	@cat ${DATA}/Unix/students.txt | awk '{print $$1}'
	@cat ${DATA}/Unix/students.txt | awk 'NR>1 {print $$1}'
	@cat ${DATA}/Unix/students.txt | awk '$$1~/^M/ {print $$1}'
	@cat ${DATA}/Unix/students.txt | awk '$$1~/[ic]/ {print $$1}'
	@cat ${DATA}/Unix/students.txt | awk '$$2~/Bio/ {print}'
	@cat ${DATA}/Unix/students.txt | awk '$$3>2'
	@cat ${DATA}/Unix/students.txt | awk '$$3>2 {print $$1}'
	@cat ${DATA}/Unix/students.txt | awk 'NR>1 && $$3>2 {print $$1}'
	@cat ${DATA}/Unix/students.txt | awk '$$2~/Bio/ && $$3>2 {print $$1}'
	@cat ${DATA}/Unix/students.txt | awk '$$2~/Chem/ && $$3==2 {print $$1}'
	@cat ${DATA}/Unix/faust_long.txt | sed -n '17p'
	@cat ${DATA}/Unix/faust_long.txt | sed -n '17,19p'
	@cat ${DATA}/Unix/faust_long.txt | sed '/\.$$/d'
	@cat ${DATA}/Unix/faust_long.txt | sed '/^$$/d'

test_bioinfformats_hpylori:
	@ls -la -h ${DATA}/Unix/Helicobacter_pylori_B8.*
	@du -h ${DATA}/Unix/Helicobacter_pylori_B8.*
	@for f in `find ${DATA}/Unix/ -type f -name "Helicobacter_pylori_B8*" | sort`; do tf=`basename $$f | rev | cut -b 4- | rev`;  zcat $$f > $$tf; ls -lah $$tf; done
	@zcat ${DATA}/Unix/Helicobacter_pylori_B8.faa.gz | grep -c "^>"
	@zcat ${DATA}/Unix/Helicobacter_pylori_B8.gbff.gz | grep -c -E "^\s+CDS\s+"
	@zcat ${DATA}/Unix/Helicobacter_pylori_B8.gbff.gz | grep -c -E "^\s+CDS\s+complement"
	@zcat ${DATA}/Unix/Helicobacter_pylori_B8.gbff.gz | grep -c -E "^\s+CDS\s+[0-9]"
