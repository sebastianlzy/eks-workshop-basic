#!/bin/zsh

export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account" )

# Retrieve aws-auth configmap from K8
kubectl get configmap -n kube-system aws-auth -o yaml | grep -v "creationTimestamp\|resourceVersion\|selfLink\|uid" | sed '/^  annotations:/,+2 d' > aws-auth.yaml

# Create the user to merge to aws-auth
cat << EoF >> aws-user.yaml
data:
  mapUsers: |
    - userarn: arn:aws:iam::${ACCOUNT_ID}:user/rbac-user
      username: rbac-user
EoF

# Merge the 2 yaml files
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' aws-auth.yaml aws-user.yaml > aws-auth-with-user.yaml

# Verify value
yq e aws-auth-with-user.yaml

# Apply configmap
kubectl apply -f aws-auth-with-user.yaml

# Verify updated value
kubectl get configmap -n kube-system aws-auth -o yaml  | yq e

# Clean up temporary files
rm aws-auth-with-user.yaml
rm aws-auth.yaml
rm aws-user.yaml