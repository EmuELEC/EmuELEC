FROM arm64v8/ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y locales sudo \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN adduser --disabled-password --gecos '' docker \
 && adduser docker sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update && apt-get install -y \
    wget bash bc gcc sed patch patchutils tar bzip2 gzip perl gawk gperf zip unzip diffutils texinfo lzop python python3 \
    g++ xfonts-utils xfonts-utils xfonts-utils xsltproc default-jre-headless cpio \
    libc6-dev libncurses5-dev libssl-dev \
    u-boot-tools \
    xz-utils make file libxml-parser-perl \
    libjson-perl libparse-yapp-perl \
    golang-go \
    git openssh-client \
    qemu-user-binfmt \
    --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

USER docker
