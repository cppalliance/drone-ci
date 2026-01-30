#!/bin/bash

set -xe
image=cppalliance/droneubuntu2404:filc
echo image is $image
docker build -t $image .
echo $?
# if [ "$?" = "0" ] ; then
#     docker push $image
# fi
