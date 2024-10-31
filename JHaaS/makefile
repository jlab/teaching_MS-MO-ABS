CONDA=mamba
SUBDIR_CONDA=Envs

PRFIX_DIR=$(shell grep "dir_dist:" settings.yaml | cut -d ":" -f 2 | tr -d " ")
PROXY=$(shell grep "proxy:" settings.yaml | cut -d ":" -f 2- | tr -d " ")
PROXY_ADDRESS=$(shell echo ${PROXY} | sed 's~http[s]*://~~g' | sed 's~:[0-9]\+$$~~g')
PROXY_CMD=$(shell ping -c 1 -q ${PROXY_ADDRESS} 2> /dev/null > /dev/null && echo "export http_proxy=${PROXY} && export https_proxy=${PROXY} && export ftp_proxy=${PROXY}" || echo "")

build: ${PRFIX_DIR}/${SUBDIR_CONDA}/Build

# create an initial conda environment to install snakemake
${PRFIX_DIR}/${SUBDIR_CONDA}/Build: Envs/env_build.yaml settings.yaml
	if [ ! -d ${PRFIX_DIR}/${SUBDIR_CONDA}/Build ]; then ${PROXY_CMD} && ${CONDA} env create -d -p "${PRFIX_DIR}/${SUBDIR_CONDA}/Build" --file Envs/env_build.yaml; fi;
