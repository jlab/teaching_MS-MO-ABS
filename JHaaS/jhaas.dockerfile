# wie koennen die User untereinander Dateien austauschen?
# wieso gibt es zu viele Layer im Testcontainer?

FROM quay.io/jupyter/scipy-notebook

# install missing ubuntu packages
USER root
RUN apt-get -y update
RUN apt-get -y install bc bsdmainutils time

# variables for docker file
ARG CE_TOUR=bioinftour
ARG CE_NGS=ngs
ARG CE_RNASEQ=rnaseq
ARG CE_CHIPSEQ=chipseq
ARG BRANCH=exercises

ARG NB_UID=1000
ARG NB_HOME=/home/jovyan
ARG NB_USER=jovyan

# one directory that shall contain pre-fetched reference data
ARG DIR_REFERENCES=${NB_HOME}/biodata

# --- do not delete! this block is important! ---
USER root

RUN mkdir -p /data
RUN chown -R "${NB_UID}:${NB_UID}" /data

USER ${NB_UID}

WORKDIR "${HOME}"
# --- do not delete! this block is important! ---

# to let students experiment with chmod, we need to have multiple user groups
USER root
RUN groupadd biologists
RUN groupadd chemists
RUN useradd joe -g biologists
RUN useradd max -g chemists
RUN usermod -a  -G biologists ${NB_USER}

# create conda environment for bioinformatics tour
USER ${NB_UID}
COPY env_tour.yaml env_tour.yaml
RUN mamba env create --yes --name ${CE_TOUR} --file env_tour.yaml 
# to be in sync with screenshots in my slides
RUN ln -s /opt/conda/envs/${CE_TOUR}/bin/cd-hit /opt/conda/envs/${CE_TOUR}/bin/cdhit
# fix a bug in pandas / dask / pyarrow
RUN sed -e "s/import dask.dataframe as dd/import dask.dataframe as dd\nfrom dask import config as dask_config\ndask_config.set({\"dataframe.convert-string\": False})/" -i /opt/conda/envs/${CE_TOUR}/lib/python*/site-packages/condastats/cli.py

# create conda environment for NGS analyes
COPY env_ngs.yaml env_ngs.yaml
RUN mamba env create --yes --name ${CE_NGS} --file env_ngs.yaml 

# install Venn diagram lib and statannot lib for python lecture in the conda base environment
SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]
RUN mamba install --yes -c conda-forge matplotlib-venn statannotations

# create conda environment for RNAseq analyes
COPY env_rnaseq.yaml env_rnaseq.yaml
RUN mamba env create --yes --name ${CE_RNASEQ} --file env_rnaseq.yaml

# create conda environment for DEseq2
COPY env_dge.yaml env_dge.yaml
RUN mamba env create --yes --name dge --file env_dge.yaml

# create conda environment for ChIPseq analyes
COPY env_chipseq.yaml env_chipseq.yaml
RUN mamba env create --yes --name ${CE_CHIPSEQ} --file env_chipseq.yaml

# hack homer such that it uses the externally provided data directory
SHELL ["conda", "run", "-n", "chipseq", "/bin/bash", "-c"]
RUN cd $CONDA_PREFIX/share/homer && mv data old_data && ln -s /Data/ChIPseq/homer/data .
RUN sed 's#^ORGANISMS#ORGANISMS\nhuman\tv7.0\tHomo sapiens (human) accession and ontology information\thttp://homer.ucsd.edu/homer/data/organisms/human.v7.0.zip\tdata/accession/\t9606,NCBI Gene#' -i $CONDA_PREFIX/share/homer/config.txt
RUN sed 's#^GENOMES#GENOMES\nhg19\tv7.0\thuman genome and annotation for UCSC hg19\thttp://homer.ucsd.edu/homer/data/genomes/hg19.v7.0.zip\tdata/genomes/hg19/\thuman,default#' -i $CONDA_PREFIX/share/homer/config.txt
