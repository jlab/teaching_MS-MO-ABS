# wie koennen die User untereinander Dateien austauschen?
# wieso gibt es zu viele Layer im Testcontainer?

FROM jupyter/scipy-notebook 

# install missing ubuntu packages
USER root
RUN apt-get -y update
RUN apt-get -y install bc

# variables for docker file
ARG CE_TOUR=bioinftour
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
RUN conda env create --yes --name ${CE_TOUR} --file msmoabs_tour.yaml 

RUN git clone -b ${BRANCH} https://github.com/jlab/teaching_MS-MO-ABS.git

# to be in sync with screenshots in my slides
RUN ln -s /opt/conda/envs/${CE_TOUR}/bin/cd-hit /opt/conda/envs/${CE_TOUR}/bin/cdhit

# TODO: move to the top!
USER root
RUN apt-get -y install bsdmainutils
USER ${NB_UID}
