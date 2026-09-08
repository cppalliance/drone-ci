#!/bin/bash

# Delete ami and the associated snapshot

set -xe

usage() {
    echo "Usage: $0 -e <dev|prod>"
    echo "  -e  Environment (required): dev or prod"
    exit 1
}

while getopts "e:" opt; do
    case "$opt" in
        e) build_environment="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ "$build_environment" != "dev" ] && [ "$build_environment" != "prod" ]; then
    echo "ERROR: -e <dev|prod> is required"
    usage
fi

if [ "$build_environment" = "dev" ]; then
    export AWS_PROFILE=tagr-packer-dev
else
    export AWS_PROFILE=tagr-packer-prod
fi

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

test="
"

amis="
ami-0a8269d79315a9e3d
ami-01b92a1970af9296b
ami-00c04b71cef1a5bfe
ami-020a480b4a9b387b4
ami-0db01cdf3903126ac
ami-070cbf1c4c9c14f42
ami-07c47efa0341abd36
ami-08dae6e96caefbb16
ami-09c519fa0b5fdaaa5
ami-015250959ccf6f26e
ami-02da422856e2b6a3e
ami-0d65c1ee465c5417a
ami-07a6dc1b17d6ab980
ami-0ef8bfd8c37404cb6
"

region=us-east-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --region $region --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --region $region --snapshot-id $SNAPSHOT; done
done
