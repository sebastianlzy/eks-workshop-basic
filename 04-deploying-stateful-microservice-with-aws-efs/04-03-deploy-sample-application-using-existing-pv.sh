#!/bin/zsh

# Download storage class/persistent volume and persistent volume claim
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-pvc.yaml
sed -e "s/EFS_VOLUME_ID/$FILE_SYSTEM_ID/g" efs-pvc.yaml > efs-pvc-with-efs-volume-id.yaml

# Create the resources
kubectl apply -f efs-pvc-with-efs-volume-id.yaml

# Retrieve the PVC
kubectl get pvc -n storage

# Expected output
#NAMESPACE   NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# storage     efs-storage-claim   Bound    efs-pvc                                    5Gi        RWX            efs-sc         40s

# Verify the corresponding pv
kubectl get pv

# Expected output
#NAMESPACE   NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
#storage     efs-storage-claim   Bound    efs-pvc                                    5Gi        RWX            efs-sc         40s

# Deploy the stateful service
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-writer.yaml
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-reader.yaml
kubectl apply -f efs-writer.yaml
kubectl apply -f efs-reader.yaml

# exec into the pod to verify efs-writer is writing data
kubectl exec -it efs-writer -n storage -- tail /shared/out.txt

# exec into the pod to verify efs-reader is reading the same data
kubectl exec -it efs-reader -n storage -- tail /shared/out.txt

# Clean up
rm efs-pvc.yaml
rm efs-pvc-with-efs-volume-id.yaml
rm efs-writer.yaml
rm efs-reader.yaml
