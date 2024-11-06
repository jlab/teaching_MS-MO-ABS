CONDA=mamba
SUBDIR_CONDA=Envs
CONDA_ENVNAME=snakemake

PREFIX_DIR=$(shell grep "dir_dist:" settings.yaml | cut -d ":" -f 2 | tr -d " ")
PROXY=$(shell grep "proxy:" settings.yaml | cut -d ":" -f 2- | tr -d " ")
PROXY_ADDRESS=$(shell echo ${PROXY} | sed 's~http[s]*://~~g' | sed 's~:[0-9]\+$$~~g')
#PROXY_CMD=$(shell ping -c 1 -q ${PROXY_ADDRESS} 2> /dev/null > /dev/null && echo "export http_proxy=${PROXY} && export https_proxy=${PROXY} && export ftp_proxy=${PROXY}" || echo "")

DIR_REPO=/media/jlu/homes/sjanssen/Git/jlab/teaching_MS-MO-ABS/JHaaS
#srun --mem=4G --pty bash

build: ${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}
	echo "Don't forget to set the proxy, if in BCF infrastructure!"

# create an initial conda environment to install snakemake
${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}: Envs/env_${CONDA_ENVNAME}.yaml settings.yaml
	if [ ! -d ${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME} ]; then ${CONDA} env create -p "${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}" --file Envs/env_${CONDA_ENVNAME}.yaml; fi;

##Envs/env_tour.yaml Envs/env_rnaseq.yaml
#image_build_docker:
#	mkdir -p no_backup/docker/Envs/
#	cp ${DIR_REPO}/Envs/env_tour.yaml ${DIR_REPO}/Envs/env_rnaseq.yaml no_backup/docker/Envs/
#	cp ${DIR_REPO}/jhaas.dockerfile .
#	sudo docker build no_backup/docker/ -f jhaas.dockerfile -t jhaas_msmoabs
#
#image_test_docker: image_build_docker
#	cp ${DIR_REPO}/jhaas_tests.dockerfile .
#	cp ${DIR_REPO}/jhaas_tests.make ${DIR_REPO}/python_intro.ipynb no_backup/docker/
#	sudo docker build no_backup/docker/ -f jhaas_tests.dockerfile -t jhaas_msmoabs_test
#	#sudo docker build --no-cache no_backup/docker/ -f jhaas_tests.dockerfile -t jhaas_msmoabs_test
##--cgroup-manager=cgroupfs 

