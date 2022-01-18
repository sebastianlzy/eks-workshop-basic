#!/bin/zsh

# Create mysql statefulset
wget https://eksworkshop.com/beginner/170_statefulset/statefulset.files/mysql-statefulset.yaml
yq e mysql-statefulset.yaml

# Apply mysql statefulset
kubectl apply -f mysql-statefulset.yaml

# Watch statefulset
kubectl -n mysql rollout status statefulset mysql

# Verify pod creation
kubectl -n mysql get pods -l app=mysql

# Check the dynamically created the PVC
kubectl -n mysql get pvc -l app=mysql

# Cleanup
rm mysql-statefulset.yaml