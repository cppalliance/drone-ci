#!/bin/bash

# note: as of 2026-09-08 s390x still isn't building.

image=cppalliance/${PWD##*/}:multiarch
docker buildx build --platform linux/arm64,linux/amd64,linux/s390x -t $image --push .
