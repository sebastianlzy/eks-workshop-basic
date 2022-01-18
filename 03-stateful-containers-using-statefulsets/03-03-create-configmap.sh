#!/bin/zsh

# Create new mysql namespace
kubectl create namespace mysql


# Create configmap for mysql
cat << EoF > mysql-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: mysql
  labels:
    app: mysql
data:
  master.cnf: |
    # Apply this config only on the leader.
    [mysqld]
    log-bin
  slave.cnf: |
    # Apply this config only on followers.
    [mysqld]
    super-read-only
EoF

# Apply mysql configmap
kubectl create -f mysql-configmap.yaml

# Verify that Configmap is created
kubectl get cm -n mysql -o yaml | yq e

# Cleanup
rm mysql-configmap.yaml