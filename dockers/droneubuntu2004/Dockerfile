
FROM ubuntu:20.04
ARG OSVERSION=20.04
ARG CLANGVERSION=11.0.0
ARG CLANGBASEURL=https://github.com/llvm/llvm-project/releases/download/llvmorg-$CLANGVERSION
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata && apt-get -o Acquire::Retries=3 install -y sudo software-properties-common wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ python3 python3-pip ruby cpio pkgconf ccache && apt-get install -y gcc-multilib || true && apt-get install -y g++-multilib || true &&  rm -rf /var/lib/apt/lists/*
RUN for i in {1..3}; do apt-add-repository ppa:git-core/ppa && break || sleep 2; done 
RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install git && rm -rf /var/lib/apt/lists/*
# Upstream LLVM binaries exist for x86_64 (ubuntu-suffixed tarball) and
# aarch64 (differently-named tarball, no ubuntu suffix), but not for s390x,
# which falls back to the distro clang package symlinked to the same path.
# Note: asset names vary between LLVM releases; recheck when bumping CLANGVERSION.
RUN case "$(uname -m)" in \
      x86_64)  CLANGFILE=clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz ;; \
      aarch64) CLANGFILE=clang+llvm-$CLANGVERSION-aarch64-linux-gnu.tar.xz ;; \
      *)       CLANGFILE= ;; \
    esac \
    && if [ -n "$CLANGFILE" ]; then \
         wget -q $CLANGBASEURL/$CLANGFILE \
         && mkdir -p /usr/local/clang+llvm-$CLANGVERSION \
         && tar xf $CLANGFILE -C /usr/local/clang+llvm-$CLANGVERSION --strip-components=1 \
         && rm $CLANGFILE ; \
       else \
         apt-get -o Acquire::Retries=3 update \
         && apt-get -o Acquire::Retries=3 -y install clang-${CLANGVERSION%%.*} \
         && rm -rf /var/lib/apt/lists/* \
         && ln -s /usr/lib/llvm-${CLANGVERSION%%.*} /usr/local/clang+llvm-$CLANGVERSION ; \
       fi
ENV PATH="/usr/local/clang+llvm-$CLANGVERSION/bin:$PATH"
RUN ln -s /usr/bin/python3 /usr/bin/python
# RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN pip3 install cmake
# Not available on 20.04:
# RUN apt-get install -y libc++-helpers
RUN if uname -p | grep -q 'x86_64'; then dpkg --add-architecture i386 ; fi
# rearrange later
#RUN apt-get -o Acquire::Retries=3 update && apt-get -o Acquire::Retries=3 -y install _ && rm -rf /var/lib/apt/lists/*
