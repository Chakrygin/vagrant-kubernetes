#!/usr/bin/env bash

echo "############################################################"
echo "## Setup master node...                                   ##"
echo "############################################################"

hostname=$(hostname -I | awk '{print $2}')

mkdir -p "/vagrant/.tmp"

kubeadm init \
    --apiserver-advertise-address="$hostname" \
    --pod-network-cidr="10.10.0.0/16" | tee "/vagrant/.tmp/join.txt"

cat "/vagrant/.tmp/join.txt" | grep -A 1 '^kubeadm' >"/vagrant/.tmp/join.sh"

mkdir -p "/root/.kube"
cp "/etc/kubernetes/admin.conf" "/root/.kube/config"

mkdir -p "/home/vagrant/.kube"
cp "/etc/kubernetes/admin.conf" "/home/vagrant/.kube/config"
chown "vagrant" "/home/vagrant/.kube/config"

mkdir -p "/vagrant/.kube"
cp "/etc/kubernetes/admin.conf" "/vagrant/.kube/config"
