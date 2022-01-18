#!/bin/zsh

# A StorageClass provides a way for administrators to describe the "classes" of storage they offer.
# Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by the cluster administrators.
# Kubernetes itself is unopinionated about what classes represent.
# This concept is sometimes called "profiles" in other storage systems.

# Create storage class
cat << EoF > mysql-storageclass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: mysql-gp2
provisioner: ebs.csi.aws.com # Amazon EBS CSI driver
parameters:
  type: gp2
  encrypted: 'true' # EBS volumes will always be encrypted by default
volumeBindingMode: WaitForFirstConsumer # EBS volumes are AZ specific
reclaimPolicy: Delete
mountOptions:
- debug
EoF


# Apply the storage class
kubectl create -f mysql-storageclass.yaml

# Describe the storage class
kubectl describe storageclass mysql-gp2

# Cleanup
rm mysql-storageclass.yaml
