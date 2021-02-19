#!/usr/bin/env bash

cat <<EOF | tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--cgroup-driver=systemd --node-ip=$(hostname -I | awk '{print $2}')"
EOF
