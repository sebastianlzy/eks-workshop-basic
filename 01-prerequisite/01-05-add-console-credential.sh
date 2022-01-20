#!/bin/zsh

export EKS_CLUSTER_NAME=eks-workshop-basic

export c9builder=$(aws cloud9 describe-environment-memberships --environment-id=$C9_PID | jq -r '.memberships[].userArn')
if echo ${c9builder} | grep -q user; then
	rolearn=${c9builder}
  echo Role ARN: ${rolearn}
elif echo ${c9builder} | grep -q assumed-role; then
  assumedrolename=$(echo ${c9builder} | awk -F/ '{print $(NF-1)}')
  rolearn=$(aws iam get-role --role-name ${assumedrolename} --query Role.Arn --output text)
  echo Role ARN: ${rolearn}
fi

eksctl create iamidentitymapping --cluster $EKS_CLUSTER_NAME --arn ${rolearn} --group system:masters --username admin

kubectl describe configmap -n kube-system aws-auth
