FROM ubuntu:23.04

RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    build-essential \
    gcc \
    g++ \
    clang \
    curl \
    python3 \
    python3-dev \
    ed \
    file \
    git \
    less \
    openssh-client \
    unzip \
    netcat-traditional \
    wget \
    zip \
    ca-certificates \
    gnupg \
    lsb-release

RUN apt install -y software-properties-common && \
    apt update && \
    add-apt-repository ppa:ubuntu-toolchain-r/ppa -y && \
    apt update && \
    apt install -y g++-13 gcc-13

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo >/etc/apt/sources.list.d/docker.list "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt-get update && \
    apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

RUN curl -Lo /usr/local/bin/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64 && chmod +x /usr/local/bin/bazelisk && /usr/local/bin/bazelisk

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
