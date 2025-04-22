
---

## ✅ `Dockerfile`

```Dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Core utilities
RUN apt-get update && apt-get install -y \
    wget curl unzip git build-essential \
    openjdk-11-jre-headless python3 python3-pip r-base \
    zlib1g-dev libncurses5-dev libbz2-dev liblzma-dev \
    libcurl4-openssl-dev libssl-dev perl

# FastQC
RUN wget -qO /opt/fastqc.zip https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip && \
    unzip /opt/fastqc.zip -d /opt && chmod +x /opt/FastQC/fastqc && ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc

# Trimmomatic
RUN wget -qO /opt/Trimmomatic-0.39.zip https://github.com/timflutre/trimmomatic/archive/refs/tags/v0.39.zip && \
    unzip /opt/Trimmomatic-0.39.zip -d /opt && ln -s /opt/trimmomatic-0.39 /opt/trimmomatic

# BWA
RUN cd /opt && git clone https://github.com/lh3/bwa.git && cd bwa && make && ln -s /opt/bwa/bwa /usr/local/bin/bwa

# Samtools
RUN wget -qO- https://github.com/samtools/samtools/releases/download/1.16/samtools-1.16.tar.bz2 | tar xj -C /opt && \
    cd /opt/samtools-1.16 && ./configure --prefix=/usr/local && make && make install

# GATK
RUN wget -qO /opt/gatk.zip https://github.com/broadinstitute/gatk/releases/download/4.5.0.0/gatk-4.5.0.0.zip && \
    unzip /opt/gatk.zip -d /opt && ln -s /opt/gatk-4.5.0.0/gatk /usr/local/bin/gatk

# CNVkit
RUN pip3 install cnvkit

# Manta
RUN wget -qO- https://github.com/Illumina/manta/releases/download/v1.6.0/manta-1.6.0.centos6_x86_64.tar.bz2 | tar xj -C /opt && \
    ln -s /opt/manta-1.6.0.centos6_x86_64/bin/configManta.py /usr/local/bin/configManta.py

# RMarkdown report support
RUN R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')"

# LIS output formatting tools
RUN pip3 install fpdf pandas


