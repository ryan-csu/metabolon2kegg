FROM continuumio/miniconda3

SHELL ["/bin/bash", "-c"]

RUN apt-get update -y && apt-get install -y git procps

RUN conda create -y -n reportsrender -c conda-forge  grst::reportsrender pandas numpy xlrd

RUN echo "conda activate reportsrender" >> ~/.bashrc
ENV PATH /opt/conda/envs/reportsrender/bin:$PATH
ENV CONDA_DEFAULT_ENV reportsrender

#RUN git clone https://github.com/ryan-csu/metabolon2kegg.git ./
RUN git init && git remote add origin https://github.com/ryan-csu/metabolon2kegg.git && git fetch -f && git branch master origin/master && git checkout master

