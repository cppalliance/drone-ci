#!/bin/bash

set -xe
# image=cppalliance/${PWD##*/}:1
image=cppalliance/droneubuntu2404:py313
echo image is $image
docker build -t $image .
echo $?
# if [ "$?" = "0" ] ; then
#     docker push $image
# fi
