# Jupyter Hub as a Service

We (are going to) use BCF's [Jupyter Hub as a Service](https://jhaas.gi.denbi.de/docs/) infrastructure for teaching MS-MO-ABS to our Master Biology students.
The idea is, that we provide:
  1. a podman/docker image with all necessary software installed, which is based on [quay.io/jupyter/scipy-notebook](https://quay.io/repository/jupyter/scipy-notebook?tab=tags&tag=latest)
  2. a directory containing all necessary files for the course.
Since we are teaching high throughput sequencing analysis, files are much larger than in other use cases and we need to create a smart mechanism to avoid too many simultaneous downloads of large files from the same source (as this might lead to IP blocking or throtteling).
As further goals, I also want to be able to 
  3. test the installed software within the container
  4. execute all necessary processing steps to be able to provide exemplary solutions and a gain feeling the compute resource demands.

I have therefore implemented a larger [snakemake](https://snakemake.readthedocs.io/en/stable/) pipeline, which should orchestrate all necessary compute and distribute across our [Slurm cluster](https://dokuwiki.computational.bio.uni-giessen.de/system:compute:slurm_usage).
You need to [install conda](https://docs.anaconda.com/miniconda/install/) first and should than be able to make use of the provided `makefile`. 

  1. Don't forget to set your proxy variables, if in the BCF infrastructure!
     - `export http_proxy=http://proxy.computational.bio.uni-giessen.de:3128`
     - `export https_proxy=http://proxy.computational.bio.uni-giessen.de:3128`
     - `export ftp_proxy=http://proxy.computational.bio.uni-giessen.de:3128`
  3. If `conda` is not yet available:
     - download: `curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh`
     - install: `bash ~/Miniconda3-latest-Linux-x86_64.sh`
     - initialize: `conda init`
     - and restart your terminal: `source ~/.bashrc` first!
  5. clone this repository: `git clone https://github.com/jlab/teaching_MS-MO-ABS.git`
  6. change into the subdirectory `JHaas` of your fresh repository copy: `cd teaching_MS-MO-ABS/JHaas`
  7. trigger pipeline execution, i.e. create new conda environment, download and process all data and create podman image: `make build`
  8. test your new podman image, especially the availability of externally mounted data in the image directory `/Data/`: `make run`

Ask Nils to serve your new podman image AND the data within the BCF's JHaaS.
