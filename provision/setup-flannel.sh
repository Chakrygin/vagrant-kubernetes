#!/usr/bin/env bash

curl -s "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml" |
    sed 's/10.244.0.0/10.10.0.0/g' |
    kubectl apply -f -
