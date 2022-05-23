#!/bin/bash

image=cppalliance/${PWD##*/}:1
docker build -t $image .
echo $?
exit
if [ "$?" = "0" ] ; then
    docker push $image
fi
