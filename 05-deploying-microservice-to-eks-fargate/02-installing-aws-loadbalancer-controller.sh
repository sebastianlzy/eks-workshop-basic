#!/bin/zsh


export EKS_CLUSTER_NAME=eks-workshop-basic
export AWS_REGION="ap-southeast-1"
export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account" )
export SERVICE_ACCOUNT_NAME=aws-load-balancer-controller
export IAM_POLICY_NAME=AWSLoadBalancerControllerIAMPolicy
export EKS_ADDON_CONTAINER_IMAGE_ADDRESS="602401143452.dkr.ecr.ap-southeast-1.amazonaws.com"
export LBC_VERSION="v2.3.0"

# Associate oidc provider
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster $EKS_CLUSTER_NAME \
    --approve

# Create IAM policy
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name $IAM_POLICY_NAME \
    --policy-document file://iam_policy.json
rm iam_policy.json

# Create the service account for load balancer controller

eksctl create iamserviceaccount \
  --cluster $EKS_CLUSTER_NAME \
  --namespace kube-system \
  --name $SERVICE_ACCOUNT_NAME \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/$IAM_POLICY_NAME \
  --override-existing-serviceaccounts \
  --approve

# Verify service account created
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml

# Update eks charts
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Get VPC id
export VPC_ID=$(aws eks describe-cluster \
                --name $EKS_CLUSTER_NAME \
                --query "cluster.resourcesVpcConfig.vpcId" \
                --output text)

# Install AWS Load balancer controller
helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksworkshop-eksctl \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.repository=$EKS_ADDON_CONTAINER_IMAGE_ADDRESS/amazon/aws-load-balancer-controller \
    --set region=${AWS_REGION} \
    --set image.tag="${LBC_VERSION}" \
    --set vpcId="${VPC_ID}"

# Verify the deployment is completed
kubectl -n kube-system rollout status deployment aws-load-balancer-controller
