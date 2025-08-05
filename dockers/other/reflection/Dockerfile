
FROM ubuntu:24.04
RUN apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata && apt-get -o Acquire::Retries=3 install -y sudo software-properties-common rsync wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ python-is-python3 python3-pip cmake ruby cpio pkgconf ccache && apt-get install -y gcc-multilib || true && apt-get install -y g++-multilib || true && rm -rf /var/lib/apt/lists/*

# Usual repo is https://github.com/llvm/llvm-project.git
ARG REPOSHORTNAME=clang-p2996
ARG REPOLONGNAME=https://github.com/bloomberg/clang-p2996
ARG CLANGVERSION=p2996
ARG LLVMTAG=p2996
ARG LLVMDIR=clang+llvm-p2996
ARG CPUS=8

RUN mkdir -p /opt/github && \
  cd /opt/github && \
  git clone -b $LLVMTAG $REPOLONGNAME && \
  cd $REPOSHORTNAME && \
  mkdir build && \
  cd build && \
  cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' -DLLVM_ENABLE_RUNTIMES='libcxx;libcxxabi;libc;libunwind' -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr/local/$LLVMDIR ../llvm && \
  cmake --build . -j $CPUS && \
  cmake --install . && \
  cd ../.. && \
  rm -rf $REPOSHORTNAME
ENV PATH="/usr/local/clang+llvm-$CLANGVERSION/bin:$PATH"

