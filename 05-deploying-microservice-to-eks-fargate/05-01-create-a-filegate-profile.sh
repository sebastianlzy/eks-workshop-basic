#!/bin/zsh

# Create a fargate profile
# Each profile can have up to five selectors that contain a namespace and optional labels.
export EKS_CLUSTER_NAME=eks-workshop-basic
eksctl create fargateprofile \
  --cluster $EKS_CLUSTER_NAME \
  --name game-2048 \
  --namespace game-2048

eksctl get fargateprofile \
  --cluster $EKS_CLUSTER_NAME \
  -o yaml