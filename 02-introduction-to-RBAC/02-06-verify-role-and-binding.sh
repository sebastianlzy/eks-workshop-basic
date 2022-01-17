#!/bin/zsh

# Switch to rbacuser
. ./rbacuser_creds.sh

# Verify that we are using the rbac-user
aws sts get-caller-identity | jq

# Retrieve pods from namespace, rbac-test
kubectl get pods -n rbac-test

# Try retrieving pods from default namespace
kubectl get pods -n kube-system