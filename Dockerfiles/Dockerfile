FROM ubuntu:23.04

LABEL description="Ubuntu 23.04 for default C++20 support"

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

RUN update-alternatives --install /usr/bin/gcc              gcc          /usr/bin/gcc-14          10 \
    && update-alternatives --install /usr/bin/g++           g++          /usr/bin/g++-14          10 \
    && update-alternatives --install /usr/bin/clang++       clang++      /usr/bin/clang++-18      10 \
    && update-alternatives --install /usr/bin/clang         clang        /usr/bin/clang-18        10 \
    && update-alternatives --install /usr/bin/cc            cc           /usr/bin/gcc-14          10 \
    && update-alternatives --install /usr/bin/c++           c++          /usr/bin/g++-14          10

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo >/etc/apt/sources.list.d/docker.list "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt-get update && \
    apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

RUN curl -LJO /usr/local/bin/bazelisk "https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64" \
    && chmod +x /usr/local/bin/bazelisk \
    && /usr/local/bin/bazelisk

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
