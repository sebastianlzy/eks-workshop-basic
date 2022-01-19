#!/bin/zsh

export EKS_CLUSTER_NAME=eks-workshop-basic





# Launching the cluster
envsubst < cluster-config.yaml | eksctl create cluster -f -