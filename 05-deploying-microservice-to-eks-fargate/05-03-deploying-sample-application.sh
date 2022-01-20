#!/bin/zsh

# Deploy sample application
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/examples/2048/2048_full.yaml

# Check deployment status
kubectl -n game-2048 rollout status deployment deployment-2048

# Get all nodes
kubectl get nodes