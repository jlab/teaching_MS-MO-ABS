SHELL := /bin/bash

CONDA=mamba
SUBDIR_CONDA=Envs
CONDA_ENVNAME=snakemake

PREFIX_DIR=$(shell grep "dir_dist:" settings.yaml | cut -d ":" -f 2 | tr -d " ")
PROXY=$(shell grep "proxy:" settings.yaml | cut -d ":" -f 2- | tr -d " ")
PROXY_ADDRESS=$(shell echo ${PROXY} | sed 's~http[s]*://~~g' | sed 's~:[0-9]\+$$~~g')

IMAGETAG=$(shell grep "tagprefix:" settings.yaml | cut -d ":" -f 2 | tr -d " ")
#PROXY_CMD=$(shell ping -c 1 -q ${PROXY_ADDRESS} 2> /dev/null > /dev/null && echo "export http_proxy=${PROXY} && export https_proxy=${PROXY} && export ftp_proxy=${PROXY}" || echo "")

build: ${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}
	@if [ `env | grep -e proxy -c` -eq 0 ]; then echo "You probably forgot to set the proxy in our BCF infrastructure.\nIf not, remove line 14 if the makefile to avoid this test."; false; fi
	condabin=`which conda`; dirconda=`dirname $$condabin`/../; source $$dirconda/etc/profile.d/conda.sh; conda activate ${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}; \
	pwd=`readlink -f .`; snakemake --profile $$pwd/slurm/ -p all

# create an initial conda environment to install snakemake
${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}: env_${CONDA_ENVNAME}.yaml settings.yaml
	@if [ ! -d ${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME} ]; then ${CONDA} env create -p "${PREFIX_DIR}/${SUBDIR_CONDA}/${CONDA_ENVNAME}" --file env_${CONDA_ENVNAME}.yaml; fi;
	@echo "conda environment for snakemake has been created"

run:
	podman run -v ${PREFIX_DIR}/Generated:/Data/ -e http_proxy="${PROXY}" -e https_proxy="${PROXY}" -e ftp_proxy="${PROXY}" -i -t ${IMAGETAG} /bin/bash