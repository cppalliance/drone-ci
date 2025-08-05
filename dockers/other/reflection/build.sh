#!/bin/bash

set -xe
image=cppalliance/${PWD##*/}:1
image=cppalliance/2404-p2996:1
echo image is $image
# docker build -t $image .
# docker build --no-cache --progress=plain -t $image . 2>&1 | tee build.log
docker build --progress=plain -t $image . 2>&1 | tee output.txt

echo $?
# if [ "$?" = "0" ] ; then
#     docker push $image
# fi
