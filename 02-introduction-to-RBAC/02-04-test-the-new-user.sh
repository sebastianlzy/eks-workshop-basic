#!/bin/zsh

# Switch to new user
. ./rbacuser_creds.sh

# Verify the caller identity
aws sts get-caller-identity | jq

# Retrieve pods from rbac-test namespace
kubectl get pods -n rbac-test

# Reset access
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID