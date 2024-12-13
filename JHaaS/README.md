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
  6. change into the subdirectory `JHaaS` of your fresh repository copy: `cd teaching_MS-MO-ABS/JHaaS`
  7. trigger pipeline execution, i.e. create new conda environment, download and process all data and create podman image: `make build`
  8. test your new podman image, especially the availability of externally mounted data in the image directory `/Data/`: `make run`

Ask Nils to serve your new podman image AND the data within the BCF's JHaaS. The directory, containing necessary files for the course, should have been created as the sub-directory `teaching_MS-MO-ABS/JHaaS/no_backup/Generated`. It currently - 2024-12-10 - contains 6.518 items, totalling in 76.6 GB.

Resource requirenments for the image might be derived from snakemakes benchmark logging:
![image](https://github.com/user-attachments/assets/dfc461be-10dd-45d8-b99f-dfdea757b0c7)

## Test your notebook server 'locally', i.e. within the BCF infrastructure, but outside of JHaaS

1. start your container image and forward jupyter's default port 8888 to the host machine (note down the host machine name, e.g. `cli.intra`): `podman run -v ./ChIPseq/chipseq.tests.make:/home/jovyan/makefile -v ./no_backup/Generated:/Data/ -e http_proxy="http://proxy.computational.bio.uni-giessen.de:3128" -e https_proxy="http://proxy.computational.bio.uni-giessen.de:3128" -e ftp_proxy="http://proxy.computational.bio.uni-giessen.de:3128" -p 8888:8888 -i -t jhaas_msmoabs`
    - we mount one of the makefiles for testing here: `-v ./ChIPseq/chipseq.tests.make:/home/jovyan/makefile`
    - we also mount the generated data: `-v ./no_backup/Generated:/Data/`
    - and enable proxy use: `-e http_proxy="http://proxy.computational.bio.uni-giessen.de:3128" -e https_proxy="http://proxy.computational.bio.uni-giessen.de:3128" -e ftp_proxy="http://proxy.computational.bio.uni-giessen.de:3128"`
    - forward the port: `-p 8888:8888`
    - and run the container image tagged `jhaas_msmoabs`: -t jhaas_msmoabs
2. we need a mechanism to browse from our local laptop to the just started jupyter service.
    1. store the `firesocks.sh` script within a directory in your PATH variable
    2. create a new firefox profile with the name `bcf-prox` (command line: `firefox --profilemanager` or within firefox browse to `about:profiles`)
    3. start the newly created firefox profile and choose "Settings" -> "Network Setting" and ensure that you are using a "Manual proxy configuration" with "SOCKS Host" set to `127.0.0.1`, SOCKS v5 activated and "Proxy DNS when using SOCKS v5" ticked, like here: ![image](https://github.com/user-attachments/assets/a1087df3-aa5f-45e9-8dd9-3837171b9ddc)
    4. You should than be able to call the script like `firesocks.sh sjanssen@login.computational.bio.uni-giessen.de 12301 bcf-prox`, where you have to replace `sjanssen` with your BCF user name!
    5. The script opens up a new firefox window with the `bcf-prox` profile. Remember on which machine you started your podman container (in this example it is `cli.intra`) and browse to `http://cli.intra:8888`.
  
## JHaaS infos
  - The $HOME dir of the default user `jovyan` is "replaced" by something that is mounted from Nil's JHaaS infrastructure, i.e. instructions in e.g. ~/bashrc are overwritten. Better use `/etc/bash.bashrc` instead.
  - An idle notebook is forced to exit after ~1 hour. It will be restarted when required, but only the $HOME dir data are "persistent" to the container. Changes in other locations will be lost!

