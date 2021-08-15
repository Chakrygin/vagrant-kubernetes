#!/usr/bin/env bash

echo "############################################################"
echo "## Variables...                                           ##"
echo "############################################################"

NODE_NAME=$(hostname)
NODE_IP=$(hostname -I | awk '{print $2}')

echo "NODE_NAME: $NODE_NAME"
echo "NODE_IP: $NODE_IP"

echo "############################################################"
echo "## Installing mc, net-tools...                            ##"
echo "############################################################"

apt-get -y update
apt-get -y install mc net-tools

echo "############################################################"
echo "## Installing kubeadm, kubelet and kubectl...             ##"
echo "############################################################"

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Update the apt package index and install packages needed to use the Kubernetes apt repository:
apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
apt-get -y update
apt-get -y install kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "############################################################"
echo "## Installing containerd...                               ##"
echo "############################################################"

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

# Install and configure prerequisites:
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

## ========================================

# Install containerd:
apt-get -y update
apt-get -y install containerd

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd

echo "############################################################"
echo "## Setup node...                                          ##"
echo "############################################################"

cat <<EOF | tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--node-ip=$NODE_IP"
EOF

if [[ "$NODE_NAME" == *"master"* ]]; then

    echo "############################################################"
    echo "## Setup master node...                                   ##"
    echo "############################################################"

    mkdir -p "/vagrant/.tmp"

    kubeadm init \
        --apiserver-advertise-address="$NODE_IP" \
        --apiserver-cert-extra-sans="" \
        --pod-network-cidr="10.10.0.0/16" | tee "/vagrant/.tmp/init.txt"

    cat "/vagrant/.tmp/init.txt" | grep -A 1 '^kubeadm' >"/vagrant/.tmp/join.sh"

    # Copy config
    mkdir -p "/root/.kube"
    cp "/etc/kubernetes/admin.conf" "/root/.kube/config"

    mkdir -p "/home/vagrant/.kube"
    cp "/etc/kubernetes/admin.conf" "/home/vagrant/.kube/config"
    chown "vagrant" "/home/vagrant/.kube/config"

    mkdir -p "/vagrant/.kube"
    cp "/etc/kubernetes/admin.conf" "/vagrant/.kube/config"

    # Allow scheduling of pods on the master
    kubectl taint node "$NODE_NAME" "node-role.kubernetes.io/master:NoSchedule-"

    echo "############################################################"
    echo "## Installing helm...                                     ##"
    echo "############################################################"

    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

    echo "############################################################"
    echo "## Setup flannel...                                       ##"
    echo "############################################################"

    curl -s "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml" |
        sed 's/10.244.0.0/10.10.0.0/g' |
        kubectl apply -f -

    echo "############################################################"
    echo "## Setup haproxy ingress...                               ##"
    echo "############################################################"

    helm repo add haproxy-ingress "https://haproxy-ingress.github.io/charts"

    helm install haproxy-ingress haproxy-ingress/haproxy-ingress \
        --create-namespace \
        --namespace ingress-haproxy \
        --version 0.13.0 \
        --set controller.hostNetwork=true

    # # curl -s "https://raw.githubusercontent.com/kubernetes/ingress-nginx/v1.0.0-alpha.1/deploy/static/provider/baremetal/deploy.yaml" |
    # #     kubectl apply -f -

    # # # TODO: Fix ValidatingWebhookConfiguration
    # # kubectl delete ValidatingWebhookConfiguration/ingress-nginx-admission

    # # kubectl patch service/ingress-nginx-controller \
    # #     --namespace ingress-nginx \
    # #     --patch '{"spec":{"externalIPs":["'$NODE_IP'"]}}'

    echo "############################################################"
    echo "## Setup kube-dns...                                      ##"
    echo "############################################################"

    kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  upstreamNameservers: |
    ["8.8.8.8"]
EOF

    sleep 1

    kubectl rollout restart deployment/coredns \
        --namespace kube-system

elif [[ "$NODE_NAME" == *"worker"* ]]; then

    echo "############################################################"
    echo "## Setup worker node...                                   ##"
    echo "############################################################"

    /vagrant/.tmp/join.sh

    # Copy config
    mkdir -p "/root/.kube"
    cp "/vagrant/.kube/config" "/root/.kube/config"

    mkdir -p "/home/vagrant/.kube"
    cp "/vagrant/.kube/config" "/home/vagrant/.kube/config"
    chown "vagrant" "/home/vagrant/.kube/config"

    # # echo "############################################################"
    # # echo "## Setup nginx ingress...                                 ##"
    # # echo "############################################################"

    # # EXTERNAL_IPS=$(
    # #     kubectl get service/ingress-nginx-controller \
    # #         --namespace ingress-nginx \
    # #         --output jsonpath='{.spec.externalIPs[*]}' | sed 's/ /\",\"/g'
    # # )

    # # kubectl patch service/ingress-nginx-controller \
    # #     --namespace ingress-nginx \
    # #     --patch '{"spec":{"externalIPs":["'$EXTERNAL_IPS'","'$NODE_IP'"]}}'

else
    echo "Unknown node type: $NODE_NAME"
    exit 1
fi
