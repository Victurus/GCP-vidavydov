#!/bin/bash

HOSTS_FILE=${1:-"./playbooks/hosts"}

INSTANCE_GROUP1_NAME=${2:-"capstonehosts_int"}
INSTANCE_GROUP2_NAME=${3:-"capstonehosts_neg"}
INSTANCE_GROUP3_NAME=${4:-"capstonehosts_mig"}

INSTANCE_G1_IP_1=$(terraform output instance_g1_ip_1)
INSTANCE_G1_IP_2=$(terraform output instance_g1_ip_2)
INSTANCE_G1_IP_3=$(terraform output instance_g1_ip_3)

INSTANCE_G2_IP_1=$(terraform output instance_g2_ip_1)
INSTANCE_G2_IP_2=$(terraform output instance_g2_ip_2)
INSTANCE_G2_IP_3=$(terraform output instance_g2_ip_3)

PROJECT_ID=$(terraform output project_id)

INSTANCES_G3_IPS="$(gcloud compute instances list --project="${PROJECT_ID}" --filter="NAME ~ capstone-mig-*" --format="value(EXTERNAL_IP)")"

cat > ${HOSTS_FILE} << EOF
[${INSTANCE_GROUP1_NAME}]
${INSTANCE_G1_IP_1}
${INSTANCE_G1_IP_2}
${INSTANCE_G1_IP_3}

[${INSTANCE_GROUP2_NAME}]
${INSTANCE_G2_IP_1}
${INSTANCE_G2_IP_2}
${INSTANCE_G2_IP_3}

[${INSTANCE_GROUP3_NAME}]
EOF

for ip in ${INSTANCES_G3_IPS}; do
  echo ${ip} >> ${HOSTS_FILE}
done
