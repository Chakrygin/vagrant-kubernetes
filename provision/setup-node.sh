#!/usr/bin/env bash

echo
echo "############################################################"
echo "## Setup node...                                          ##"
echo "############################################################"
echo

cat <<EOF | tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--node-ip=$(hostname -I | awk '{print $2}')"
EOF
