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
COPY envs/msmoabs_tour.yaml msmoabs_tour.yaml
RUN mamba env create --yes --name ${CE_TOUR} --file msmoabs_tour.yaml 
# to be in sync with screenshots in my slides
RUN ln -s /opt/conda/envs/${CE_TOUR}/bin/cd-hit /opt/conda/envs/${CE_TOUR}/bin/cdhit

# create conda environment for RNAseq analyes
COPY envs/msmoabs_rnaseq.yaml msmoabs_rnaseq.yaml
RUN mamba env create --yes --name ${CE_RNASEQ} --file msmoabs_rnaseq.yaml 

# PREPARE DATA FOR STUDENTS
RUN mkdir ${DIR_REFERENCES}
# Copy the hg19 bowtie2 index (~7.3 GB data) into the container to save bandwidth and time
# If you use the make target 'jhaas', the files get downloaded through the make process and will be
# copied into the container. If this pre-fetch was not executed, the RUN if statement resolves to true
# and download of the files will happen from within the container
COPY foo BuildCache/hg19.*.bt2 ${DIR_REFERENCES}/
RUN  if [ ! -e ${DIR_REFERENCES}/hg19.1.bt2 ] ; then cd ${DIR_REFERENCES}; wget https://genome-idx.s3.amazonaws.com/bt/hg19.zip; unzip hg19.zip; fi

## 2. six RNAseq example datasets
COPY samples_rnaseq.txt BuildCache/RNA-seq_shScr_*.fastq.gz ${DIR_REFERENCES}/
SHELL ["conda", "run", "-n", "rnaseq", "/bin/bash", "-c"]
RUN  if [ ! -e ${DIR_REFERENCES}/RNA-seq_shScr_TNF_1.fastq.gz ] ; then export IFS=$'\x0a' && for line in `cat samples_rnaseq.txt | grep -v "^#"`; do url=`echo $line | cut -f 3`; name=`echo $line | cut -f 2 | tr " " "_"`; wget "$url"; fasterq-dump ./`basename $url` -F fastq --skip-technical; gzip `basename $url`.fastq -9; mv `basename $url`.fastq.gz $name.fastq.gz; done; fi;

RUN git clone -b ${BRANCH} https://github.com/jlab/teaching_MS-MO-ABS.git

# install Venn diagram lib for python lecture in the conda base environment
SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]
RUN conda install --yes -c conda-forge matplotlib-venn

# IFF created during make, copy trimmed, sorted bam files for RNAseq into container
COPY foo BuildCache/RNA-seq_shScr_*.bam ${DIR_REFERENCES}/


#SHELL ["conda", "run", "-n", "rnaseq", "/bin/bash", "-c"]
#COPY make_tests make_tests
#RUN  if [ ! -e ${DIR_REFERENCES}/RNA-seq_shScr_TNF_1.trimmed.sorted.bam ] && [ -e /hostDir ] ; then cd /hostDir; make -f ~/make_tests RNA-seq_shScr_TNF_1.trimmed.sorted.bam; fi;

#WORKDIR ${NB_HOME}
#
#
#
##
### TODO: move to the top!
##USER root
##RUN apt-get -y install bsdmainutils time
##USER ${NB_UID}
##
#
##USER root
##RUN mkdir -p /vonAussen && chown jovyan /vonAussen && chgrp users /vonAussen && chmod u+rwx /vonAussen 
##USER ${NB_UID}
#