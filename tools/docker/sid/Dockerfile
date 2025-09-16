FROM debian:sid

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y locales sudo \
 && rm -rf /var/lib/apt/lists/*

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN adduser --disabled-password --gecos '' docker \
 && adduser docker sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update && apt-get install -y \
    wget bash bc gcc sed patch patchutils tar bzip2 gzip xz-utils zstd perl gawk gperf zip unzip diffutils lzop make file \
    g++ xfonts-utils xsltproc default-jre-headless python3 \
    libc6-dev libncurses5-dev \
    libjson-perl libxml-parser-perl libparse-yapp-perl \
    golang-go \
    git openssh-client \
    --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

USER docker
