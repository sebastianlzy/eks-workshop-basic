#!/bin/zsh

export EKS_CLUSTER_NAME=eks-workshop-basic

# Retrieve VPC ID and CIDR group range
export VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)
export CIDR_BLOCK=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[].CidrBlock" --output text)

# Create a security group to allow NFS access to the file system from all worker nodes
MOUNT_TARGET_GROUP_NAME="eks-efs-group"
MOUNT_TARGET_GROUP_DESC="NFS access to EFS from EKS worker nodes"
MOUNT_TARGET_GROUP_ID=$(aws ec2 create-security-group --group-name $MOUNT_TARGET_GROUP_NAME --description "$MOUNT_TARGET_GROUP_DESC" --vpc-id $VPC_ID | jq --raw-output '.GroupId')
aws ec2 authorize-security-group-ingress --group-id $MOUNT_TARGET_GROUP_ID --protocol tcp --port 2049 --cidr $CIDR_BLOCK

# Create an EFS file lsb_release -a
export FILE_SYSTEM_ID=$(aws efs create-file-system | jq --raw-output '.FileSystemId')

# Check the LifeCycleState of the file system
aws efs describe-file-systems --file-system-id $FILE_SYSTEM_ID

# Identify worker node in public subnet to create a mount target

export TAG1=tag:alpha.eksctl.io/cluster-name
export TAG2=tag:kubernetes.io/role/elb
export subnets=($(aws ec2 describe-subnets --filters "Name=$TAG1,Values=$EKS_CLUSTER_NAME" "Name=$TAG2,Values=1" | jq --raw-output '.Subnets[].SubnetId'))
for subnet in ${subnets[@]}
do
    echo "creating mount target in " $subnet
    aws efs create-mount-target --file-system-id $FILE_SYSTEM_ID --subnet-id $subnet --security-groups $MOUNT_TARGET_GROUP_ID
done

aws efs describe-mount-targets --file-system-id $FILE_SYSTEM_ID | jq --raw-output '.MountTargets[].LifeCycleState'