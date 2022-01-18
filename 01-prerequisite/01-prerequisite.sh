#!/bin/zsh

export EKS_CLUSTER_NAME=eks-workshop-basic

# Installing eksctl binary
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin

# Ensure the eksctl works
eksctl version

# Launching the cluster
envsubst < cluster-config.yaml | eksctl create cluster -f -