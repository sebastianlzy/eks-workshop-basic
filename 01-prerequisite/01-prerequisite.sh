
export EKS_CLUSTER_NAME=eks-workshop-basic
#envsubst < cluster-config.yaml
envsubst < cluster-config.yaml | eksctl create cluster -f -