#!/bin/bash

# Discover amis to delete

set -e

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
    ami_list=dev_amis.sh
else
    export AWS_PROFILE=tagr-packer-prod
    ami_list=prod_amis.sh
fi

region=us-east-2
amis=""

results=$(aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region $region)

echo "all results:"
echo "$results"
echo " "

IFS='
'

for result in $results; do
    # echo "ami is $result"
    ami_name=$(echo "$result" | cut -f1)
    # echo "ami_name is $ami_name"
    ami_id=$(echo "$result" | cut -f2)
    # echo "ami_id is $ami_id"
    if grep $ami_name ../examples/multi-runner-cppal/templates/runner-configs/*.yaml ; then
        # ami is in use
        true
    elif grep $ami_name $ami_list ; then
        # ami is in use
        true
    else
        amis="${amis}\n${ami_id}"
    fi
done

echo " "
echo "to remove:"
echo -e "$amis"
echo " "
