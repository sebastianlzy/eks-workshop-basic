#!/bin/zsh

# NOTE: If you are running the following command on a cloud9 instance,
# please follow the steps in https://www.eksworkshop.com/020_prerequisites/iamrole/ instead

export CLOUD_9_INSTANCE_ROLE_NAME=cloud9-instance-profile-role
export CLOUD_9_INSTANCE_PROFILE_NAME=cloud9-instance-profile

# Define a trust relationship
cat << EoF >> cloud9-instance-profile-role-trust.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EoF

# Create the role
aws iam create-role --role-name $CLOUD_9_INSTANCE_ROLE_NAME --assume-role-policy-document file://cloud9-instance-profile-role-trust.json

# Attach administrative permission to role
aws iam attach-role-policy --role-name $CLOUD_9_INSTANCE_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create instance profile

aws iam create-instance-profile --instance-profile-name $CLOUD_9_INSTANCE_PROFILE_NAME

# Attach role to instance profile
aws iam add-role-to-instance-profile --role-name $CLOUD_9_INSTANCE_ROLE_NAME --instance-profile-name $CLOUD_9_INSTANCE_PROFILE_NAME

