#!/bin/bash
# This is the script for preparation of environment
# for terraform execution
# It have to be sourced:
#
# source prepare.sh

#set -x

grant_project_role() {
  local project=${1?project not set}
  local svcacc_name=${2?service account name not set}
  local role=${3?role not set}
  gcloud projects add-iam-policy-binding ${project} \
      --member serviceAccount:${svcacc_name}@${project}.iam.gserviceaccount.com \
        --role roles/${role}
}

grant_organization_role() {
  local organization=${1?organization not set}
  local project=${2?project not set}
  local svcacc_name=${3?service account name not set}
  local role=${4?role not set}
  gcloud organizations add-iam-policy-binding ${organization} \
      --member serviceAccount:${svcacc_name}@${project}.iam.gserviceaccount.com \
        --role roles/${role}
}

# Export variables necessary for terraform execution
USER=${1:-vidavydov}
export TF_VAR_org_id=$(gcloud organizations list --format="value(ID)" --filter="DISPLAY_NAME ~ .*")
export TF_VAR_billing_account=$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" --filter="NAME ~ .* AND OPEN=True")
export TF_ADMIN=${USER}-capstone # Main project
export TF_CREDS=~/.config/gcloud/${USER}-capstone.json
export ACCOUNT_NAME=terraform
export TF_VAR_project_name=${USER}-capstone
export TF_VAR_region=us-central1

echo -n "Project exist: "
PROJECT_EXIST="$(gcloud projects list --format="value(NAME)" --filter="NAME=${TF_ADMIN}")"

if [ -z "${PROJECT_EXIST}" ]; then
  echo "no"
  echo "Project creation..."
  gcloud projects create ${TF_ADMIN} \
    --organization ${TF_VAR_org_id} \
    --set-as-default

  gcloud beta billing projects link ${TF_ADMIN} \
      --billing-account ${TF_VAR_billing_account}
fi

echo -n "Service account exist: "
SVCACC_EXIST="$(gcloud iam service-accounts list --format='value(EMAIL)' --project="${TF_ADMIN}" --filter="EMAIL ~ ${ACCOUNT_NAME}")"

if [ -z "${SVCACC_EXIST}" ]; then
  echo "no"
  echo "Service account creation..."
  gcloud iam service-accounts create ${ACCOUNT_NAME} \
    --display-name "$(tr '[:lower:]' '[:upper:]' <<< ${ACCOUNT_NAME:0:1})${ACCOUNT_NAME:1} admin account"
  echo "Creating keys..."
  gcloud iam service-accounts keys create ${TF_CREDS} \
    --iam-account ${ACCOUNT_NAME}@${TF_ADMIN}.iam.gserviceaccount.com
fi

# Granting permissions
echo "Granting permissions..."
grant_project_role ${TF_ADMIN} ${ACCOUNT_NAME} viewer
grant_project_role ${TF_ADMIN} ${ACCOUNT_NAME} storage.admin
grant_project_role ${TF_ADMIN} ${ACCOUNT_NAME} compute.loadBalancerAdmin
echo "Enabling services..."
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com
grant_organization_role ${TF_VAR_org_id} ${TF_ADMIN} ${ACCOUNT_NAME} resourcemanager.projectCreator
grant_organization_role ${TF_VAR_org_id} ${TF_ADMIN} ${ACCOUNT_NAME} billing.user

echo -n "Bucket exist: "
BUCKET_EXIST=$(gsutil ls | grep ${TF_ADMIN})
if [ -z "${BUCKET_EXIST}" ]; then
  echo "no"
  echo "Creating bucket..."
  gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
  gsutil versioning set on gs://${TF_ADMIN}

  cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}"
   prefix  = "terraform/state"
 }
}
EOF
fi
echo "Bucket exist"

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}
