#!/bin/bash

export PROJECT_ID=cppalliance-project1
export PROJECT_NUMBER=`gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)"`

echo "Project number is $PROJECT_NUMBER"

# Create Service Account for Packer
gcloud iam service-accounts create packer --description "Packer image builder"

# Grant roles to Packer's Service Account

gcloud projects add-iam-policy-binding $PROJECT_ID \
     --role="roles/compute.instanceAdmin.v1" \
     --member="serviceAccount:packer@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
     --role="roles/iam.serviceAccountUser" \
     --member="serviceAccount:packer@${PROJECT_ID}.iam.gserviceaccount.com"

# Allow CloudBuild to impersonate Packer service account

gcloud iam service-accounts add-iam-policy-binding \
     packer@${PROJECT_ID}.iam.gserviceaccount.com \
     --role="roles/iam.serviceAccountTokenCreator" \
     --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
