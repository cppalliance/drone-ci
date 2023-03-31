#!/bin/bash

set -xe

if [ ! -n "$GH_TOKEN" ]; then
    echo "Set GH_TOKEN"
    exit 1
fi

mkdir -p tmp && cd tmp
if [ -d mrdox ]; then
  cd mrdox
  git checkout master
  git pull
  git submodule update --init
else
  git clone -b master https://${GH_TOKEN}@github.com/cppalliance/mrdox
  cd mrdox
  git submodule update --init
fi

# without module checked out
# llvmcommit=$(git submodule status | grep llvm | cut -d' ' -f1 | cut -b 2-)

# with submodule checked out
llvmcommit=$(git submodule status | grep llvm | cut -d' ' -f2)
echo "llvmcommit is $llvmcommit"
llvmshortcommit=$(echo ${llvmcommit} | cut -b 1-7 )
echo "llvmshortcommit is $llvmshortcommit"

cd ../..

image=cppalliance/droneubuntu2204:llvm-$llvmshortcommit
docker build --build-arg GH_TOKEN=${GH_TOKEN} -t $image . | tee output.txt 2>&1
echo $?
exit
if [ "$?" = "0" ] ; then
    docker push $image
fi
