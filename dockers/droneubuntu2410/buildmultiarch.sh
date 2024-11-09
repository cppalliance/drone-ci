#!/bin/bash

image=cppalliance/${PWD##*/}:multiarch
docker buildx build --platform linux/arm64,linux/amd64,linux/s390x -t $image --push .
