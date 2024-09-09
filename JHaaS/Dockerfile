# wie koennen die User untereinander Dateien austauschen?
# wieso gibt es zu viele Layer im Testcontainer?

FROM jupyter/scipy-notebook 

# install missing ubuntu packages
USER root
RUN apt-get -y update
RUN apt-get -y install bc bsdmainutils time

# variables for docker file
ARG CE_TOUR=bioinftour
ARG CE_RNASEQ=rnaseq
ARG BRANCH=exercises

ARG NB_UID=1000
ARG NB_HOME=/home/jovyan
ARG NB_USER=jovyan

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
COPY envs/msmoabs_tour.yaml msmoabs_tour.yaml
RUN mamba env create --yes --name ${CE_TOUR} --file msmoabs_tour.yaml 
# to be in sync with screenshots in my slides
RUN ln -s /opt/conda/envs/${CE_TOUR}/bin/cd-hit /opt/conda/envs/${CE_TOUR}/bin/cdhit

# create conda environment for RNAseq analyes
COPY envs/msmoabs_rnaseq.yaml msmoabs_rnaseq.yaml
RUN mamba env create --yes --name ${CE_RNASEQ} --file msmoabs_rnaseq.yaml 

# PREPARE DATA FOR STUDENTS
RUN mkdir ~/biodata/ 
# 1. hg19 bowtie2 index: ~7.3 GB data
# There are three alternative routes
#    a) download assembly and build index yourself  (takes too much compute)
#        cd ~/biodata && wget https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
#        gunzip ~/biodata/hg19.fa.gz
#        SHELL ["conda", "run", "-n", "rnaseq", "/bin/bash", "-c"]
#        bowtie2-build --threads 8 ~/biodata/hg19.fa ~/biodata/hg19_full
#    b) download from original source
#        RUN cd ~/biodata && wget https://genome-idx.s3.amazonaws.com/bt/hg19.zip && unzip hg19.zip
#    c) copy into container, if rebuilding more frequently
COPY DL/*.bt2 biodata/


RUN git clone -b ${BRANCH} https://github.com/jlab/teaching_MS-MO-ABS.git

# install Venn diagram lib for python lecture in the conda base environment
RUN mamba install --yes -c conda-forge matplotlib-venn

#
## TODO: move to the top!
#USER root
#RUN apt-get -y install bsdmainutils time
#USER ${NB_UID}
#

#USER root
#RUN mkdir -p /vonAussen && chown jovyan /vonAussen && chgrp users /vonAussen && chmod u+rwx /vonAussen 
#USER ${NB_UID}
