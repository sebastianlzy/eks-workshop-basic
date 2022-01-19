#!/bin/zsh

export EBS_CSI_POLICY_NAME="Amazon_EBS_CSI_Driver"
export AWS_REGION="ap-southeast-1"
export EKS_CLUSTER_NAME=eks-workshop-basic
export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account" )
#https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
export EKS_ADDON_CONTAINER_IMAGE_ADDRESS="602401143452.dkr.ecr.ap-southeast-1.amazonaws.com"
export SERVICE_ACCOUNT_NAME=ebs-csi-controller-irsa

# download the IAM policy document
curl -sSL -o ebs-csi-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json

# Create the IAM policy
aws iam create-policy \
  --region ${AWS_REGION} \
  --policy-name ${EBS_CSI_POLICY_NAME} \
  --policy-document file://ebs-csi-policy.json

# export the policy ARN as a variable
export EBS_CSI_POLICY_ARN=$(aws --region ${AWS_REGION} iam list-policies --query 'Policies[?PolicyName==`'$EBS_CSI_POLICY_NAME'`].Arn' --output text)

# Create an IAM OIDC provider for your cluster
eksctl utils associate-iam-oidc-provider \
  --region=$AWS_REGION \
  --cluster=$EKS_CLUSTER_NAME \
  --approve

# Create a service account
eksctl create iamserviceaccount \
  --cluster $EKS_CLUSTER_NAME \
  --name $SERVICE_ACCOUNT_NAME \
  --namespace kube-system \
  --attach-policy-arn $EBS_CSI_POLICY_ARN \
  --override-existing-serviceaccounts \
  --approve

export SERVICE_ACCOUNT_ROLE_ARN=$(aws cloudformation describe-stacks \
    --stack-name eksctl-$EKS_CLUSTER_NAME-addon-iamserviceaccount-kube-system-$SERVICE_ACCOUNT_NAME \
    --query='Stacks[].Outputs[?OutputKey==`Role1`].OutputValue' \
    --output text)

# add the aws-ebs-csi-driver as a helm repo
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

# update help repo
helm repo update

# search for the driver
helm search repo aws-ebs-csi-driver

# Install aws ebs csi - kubernetes v1.21

helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository="$EKS_ADDON_CONTAINER_IMAGE_ADDRESS/eks/aws-ebs-csi-driver" \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=$SERVICE_ACCOUNT_NAME

# Wait for deployment to rollout
kubectl -n kube-system rollout status deployment ebs-csi-controller

# Verify that the csi controller is running
kubectl get pod -n kube-system -l "app.kubernetes.io/name=aws-ebs-csi-driver,app.kubernetes.io/instance=aws-ebs-csi-driver"

# Expected Output
#ebs-csi-controller-654b9bbbd6-g7kj7   5/5     Running   0          21h
#ebs-csi-controller-654b9bbbd6-hh7z9   5/5     Running   0          21h
#ebs-csi-node-fv24n                    3/3     Running   0          21h
#ebs-csi-node-j8q9z

# Cleanup
rm ebs-csi-policy.json
