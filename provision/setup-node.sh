#!/usr/bin/env bash

echo "############################################################"
echo "## Setup node...                                          ##"
echo "############################################################"

hostname=$(hostname -I | awk '{print $2}')

cat <<EOF | tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--node-ip=$hostname"
EOF
