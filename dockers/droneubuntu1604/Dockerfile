
FROM ubuntu:16.04
ARG OSVERSION=16.04
ARG CLANGVERSION=7.0.1
ARG CLANGDOWNLOAD=https://releases.llvm.org/7.0.1/clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata && apt-get -o Acquire::Retries=3 install -y sudo software-properties-common wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ libc++-helpers python python-pip ruby cpio pkgconf python3 python3-pip ccache libpython-dev && apt-get install -y gcc-multilib g++-multilib || true && rm -rf /var/lib/apt/lists/*
# (temporary) errors on arm architecture. Let's use standard git package for now
RUN for i in {1..3}; do apt-add-repository ppa:git-core/ppa && break || sleep 2; done
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Retries=3 -y install git-man && dpkg -l | grep git && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN wget $CLANGDOWNLOAD && mkdir -p /usr/local/clang+llvm-$CLANGVERSION && tar xf clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz -C  /usr/local/clang+llvm-$CLANGVERSION --strip-components=1
ENV PATH="/usr/local/clang+llvm-$CLANGVERSION/bin:$PATH"
RUN if uname -p | grep -q 'x86_64'; then dpkg --add-architecture i386 ; fi
RUN python_version=$(python3 -c 'import sys; print("{0.major}.{0.minor}".format(sys.version_info))') && \
    wget https://bootstrap.pypa.io/pip/$python_version/get-pip.py && \
    python3 get-pip.py
RUN pip3 install cmake
# rearrange later
# RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install _ && rm -rf /var/lib/apt/lists/*
