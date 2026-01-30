
FROM ubuntu:24.04
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata && apt-get -o Acquire::Retries=3 install -y sudo software-properties-common rsync wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ python-is-python3 python3-pip cmake ruby cpio pkgconf ccache clang-18 && apt-get install -y gcc-multilib || true && apt-get install -y g++-multilib || true && rm -rf /var/lib/apt/lists/*
# RUN for i in {1..3}; do apt-add-repository ppa:git-core/ppa && break || sleep 2; done
# RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install git && rm -rf /var/lib/apt/lists/*

# See previous OS images for an llvm-download method of installing clang
RUN sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100
RUN sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100

ARG fil_c_version=0.677
RUN  set -xe \
 && mkdir -p /opt/downloads \
 && cd /opt/downloads \
 && wget "https://github.com/pizlonator/fil-c/releases/download/v${fil_c_version}/optfil-${fil_c_version}-linux-x86_64.tar.xz" \
 && tar -xvJf "optfil-${fil_c_version}-linux-x86_64.tar.xz" \
 && cd "optfil-${fil_c_version}-linux-x86_64" \
 && /bin/bash -c 'echo -e "YES\nYES" | ./setup.sh' \
 && rm -rf /opt/downloads

ENV PATH="/opt/fil/bin:${PATH}"
