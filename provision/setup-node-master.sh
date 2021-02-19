#!/usr/bin/env bash

echo
echo "############################################################"
echo "## Setup master node...                                   ##"
echo "############################################################"
echo

mkdir -p "/vagrant/.tmp"

kubeadm init \
    --apiserver-advertise-address="$(hostname -I | awk '{print $2}')" \
    --apiserver-cert-extra-sans="192.168.1.11" \
    --pod-network-cidr="10.10.0.0/16" | tee "/vagrant/.tmp/join.txt"

cat "/vagrant/.tmp/join.txt" | grep -A 1 '^kubeadm' >"/vagrant/.tmp/join.sh"

mkdir -p "/root/.kube"
cp -i "/etc/kubernetes/admin.conf" "/root/.kube/config"

mkdir -p "/vagrant/.kube"
cp -i "/etc/kubernetes/admin.conf" "/vagrant/.kube/config"

mkdir -p "/home/vagrant/.kube"
cp -i "/etc/kubernetes/admin.conf" "/home/vagrant/.kube/config"
chown "vagrant" "/home/vagrant/.kube/config"
