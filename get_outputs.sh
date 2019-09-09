#!/bin/bash

INSTANCE_GROUP_NAME="capstonehosts"
INSTANCE_IP_1=$(terraform output instance_ip_1)
INSTANCE_IP_2=$(terraform output instance_ip_2)
INSTANCE_IP_3=$(terraform output instance_ip_3)

cat > ./playbooks/hosts << EOF
[${INSTANCE_GROUP_NAME}]
${INSTANCE_IP_1}
${INSTANCE_IP_2}
${INSTANCE_IP_3}
EOF
