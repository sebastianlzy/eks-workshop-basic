
# Create rbac-test namespace

kubectl create namespace rbac-test
kubectl create deploy nginx --image=nginx -n rbac-test

# To verify the test pods were properly installed, run:

kubectl get all -n rbac-test