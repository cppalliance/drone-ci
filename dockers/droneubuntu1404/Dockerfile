
FROM ubuntu:14.04
ARG OSVERSION=14.04
ARG CLANGVERSION=5.0.0
ARG CLANGDOWNLOAD=https://releases.llvm.org/$CLANGVERSION/clang+llvm-$CLANGVERSION-linux-x86_64-ubuntu$OSVERSION.tar.xz
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata && apt-get -o Acquire::Retries=3 install -y sudo software-properties-common wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ libc++-helpers python python-pip ruby cpio pkgconf python3 python3-pip ccache libpython-dev cmake && apt-get install -y gcc-multilib g++-multilib || true && rm -rf /var/lib/apt/lists/*
RUN for i in {1..3}; do apt-add-repository ppa:git-core/ppa && break || sleep 2; done
RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install git cpio && rm -rf /var/lib/apt/lists/*
RUN wget $CLANGDOWNLOAD && mkdir -p /usr/local/clang+llvm-$CLANGVERSION && tar xf clang+llvm-$CLANGVERSION-linux-x86_64-ubuntu$OSVERSION.tar.xz -C  /usr/local/clang+llvm-$CLANGVERSION --strip-components=1
ENV PATH="/usr/local/clang+llvm-$CLANGVERSION/bin:$PATH"
# RUN python -m pip install --upgrade pip
# RUN /usr/local/bin/pip install cmake
RUN python_version=$(python3 -c 'import sys; print("{0.major}.{0.minor}".format(sys.version_info))') && \
    wget https://bootstrap.pypa.io/pip/$python_version/get-pip.py && \
    python3 get-pip.py
RUN if uname -p | grep -q 'x86_64'; then dpkg --add-architecture i386 ; fi
# Fix Let's Encrypt:
RUN cp /etc/ca-certificates.conf /etc/ca-certificates.conf.orig
RUN cat /etc/ca-certificates.conf.orig | sed 's|mozilla/DST_Root_CA_X3.crt|!mozilla//DST_Root_CA_X3.crt|g' > /etc/ca-certificates.conf
RUN dpkg-reconfigure -fnoninteractive ca-certificates

# rearrange later
# RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install _ && rm -rf /var/lib/apt/lists/*
