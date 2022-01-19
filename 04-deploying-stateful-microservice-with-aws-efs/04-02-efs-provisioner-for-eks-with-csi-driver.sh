#!/bin/zsh

export EFS_CSI_POLICY_NAME="AmazonEKS_EFS_CSI_Driver_Policy"
export AWS_REGION="ap-southeast-1"
export EKS_CLUSTER_NAME=eks-workshop-basic
export EKS_ADDON_CONTAINER_IMAGE_ADDRESS="602401143452.dkr.ecr.ap-southeast-1.amazonaws.com"
export SERVICE_ACCOUNT_NAME=efs-csi-controller-sa

# download IAM policy
curl -o iam-policy-example.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.2/docs/iam-policy-example.json

# Create the IAM policy
aws iam create-policy \
    --policy-name $EFS_CSI_POLICY_NAME \
    --policy-document file://iam-policy-example.json

# export the policy ARN as a variable
export EFS_CSI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'$EFS_CSI_POLICY_NAME'`].Arn' --output text)

# Create the service account
eksctl create iamserviceaccount \
    --name $SERVICE_ACCOUNT_NAME \
    --namespace kube-system \
    --cluster $EKS_CLUSTER_NAME \
    --attach-policy-arn $EFS_CSI_POLICY_ARN \
    --approve \
    --override-existing-serviceaccounts \
    --region $AWS_REGION

# Add helm repo
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update

#Install driver
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=$EKS_ADDON_CONTAINER_IMAGE_ADDRESS/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=$SERVICE_ACCOUNT_NAME

# Wait for deployment to rollout
kubectl -n kube-system rollout status deployment efs-csi-controller

# Verify that the efs csi controller is running
kubectl get pod -n kube-system -l "app.kubernetes.io/name=aws-efs-csi-driver,app.kubernetes.io/instance=aws-efs-csi-driver"

# Expected Output
#efs-csi-controller-6676748d47-2xcv6   3/3     Running   0          77s
#efs-csi-controller-6676748d47-5j5j9   3/3     Running   0          77s
#efs-csi-node-bhwp8                    3/3     Running   0          12m
#efs-csi-node-mrqjh                    3/3     Running   0          12m

# Cleanup
rm iam-policy-example.json