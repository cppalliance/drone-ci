
FROM ubuntu:24.04
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata && apt-get -o Acquire::Retries=3 install -y sudo software-properties-common rsync wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ python-is-python3 python3-pip cmake ruby cpio pkgconf ccache clang-18 && apt-get install -y gcc-multilib || true && apt-get install -y g++-multilib || true && rm -rf /var/lib/apt/lists/*
# RUN for i in {1..3}; do apt-add-repository ppa:git-core/ppa && break || sleep 2; done
# RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install git && rm -rf /var/lib/apt/lists/*

# See previous OS images for an llvm-download method of installing clang
RUN sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100
RUN sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100

# i386 slows down "apt update", and most likely few CI jobs require it. They may add it manually.
# RUN if uname -p | grep -q 'x86_64'; then dpkg --add-architecture i386 ; fi

RUN groupadd -g 150 jenkins
RUN useradd jenkins -u 150 -g 150 -m -s /bin/bash
RUN echo "ALL ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/all
