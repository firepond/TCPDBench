FROM ubuntu:20.04

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
	apt-get remove -y python && \
	apt-get install -y --no-install-recommends \
		git \
		build-essential \
		r-base \
		r-base-dev \
		r-cran-rcppeigen \
		latexmk \
		texlive-latex-extra \
		libcurl4-openssl-dev \
		libfontconfig1-dev \
		libfreetype6-dev \
		libfribidi-dev \
		libgit2-dev \
		libharfbuzz-dev \
		libharfbuzz0b \
		libjpeg-dev \
		liblzma-dev \
		libopenblas-dev \
		libopenmpi-dev \
		libpng-dev \
		libssl-dev \
		libtiff5-dev \
		libv8-dev \
		libxml2-dev

# Make sure python means python3
RUN apt-get install -y --no-install-recommends \
	python3 \
	python3-dev \
	python3-tk \
	python3-venv \
	python3-pip && \
    pip3 install --no-cache-dir --upgrade setuptools && \
	echo "alias python='python3'" >> /root/.bash_aliases && \
	echo "alias pip='pip3'" >> /root/.bash_aliases && \
	cd /usr/local/bin && ln -s /usr/bin/python3 python && \
	cd /usr/local/bin && ln -s /usr/bin/pip3 pip && \
    pip install virtualenv abed wheel

# Set the default shell to bash
RUN mv /bin/sh /bin/sh.old && cp /bin/bash /bin/sh

# Clone the dataset repo
RUN git clone https://github.com/alan-turing-institute/TCPD

# Build the dataset
RUN cd TCPD && make export

# Clone the repo
RUN git clone --recurse-submodules https://github.com/alan-turing-institute/TCPDBench

# Copy the datasets into the benchmark dir
RUN mkdir -p /TCPDBench/datasets && cp TCPD/export/*.json /TCPDBench/datasets/

# Install Python dependencies
RUN pip install -r /TCPDBench/analysis/requirements.txt

# Install R dependencies
RUN Rscript -e "install.packages(c('argparse', 'exactRankTests'))"

# Set the working directory
WORKDIR TCPDBench
