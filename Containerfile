FROM docker.io/debian:12.5
LABEL authors="Kosmas Hench" \
      description="Base R environment"

# install R dependencies
RUN apt update && \
    apt install -y wget procps dirmngr gnupg apt-transport-https ca-certificates software-properties-common

# setting up conda
# (this is not currently used, but set up so that conda is
# available later on for follow-up / offspring containers)
RUN mkdir -p /miniconda && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda/miniconda.sh && \
    bash /miniconda/miniconda.sh -b -u -p /miniconda && \
    rm -rf /miniconda/miniconda.sh

ENV PATH ${PATH}:/miniconda/bin

# install mamba for fast installation and set up channels
RUN conda install mamba -y -n base -c conda-forge
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge

# install R
RUN gpg --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' && \
    add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian bookworm-cran40/'
RUN apt update && \
    apt install -y openssl libudunits2-0 libudunits2-dev libgdal-dev libgsl-dev libatlas3-base git libasound2  build-essential aptitude fort77 xorg-dev liblzma-dev libblas-dev gfortran gcc-multilib gobjc++ aptitude libreadline-dev r-base-dev

ENV LC_ALL=C.UTF-8

# restrict R libs to the container (when using singularity) and fix system timezone
RUN mkdir -p /etc/R && \
    echo 'TZ="UTC"' >> /etc/R/Renviron

# setup R environment
RUN apt install -y libfreetype-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev

RUN R --slave -e 'chooseCRANmirror(ind=50); install.packages("R.utils")'
