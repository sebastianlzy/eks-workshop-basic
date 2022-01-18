#!/bin/zsh

#Kubernetes Service defines a logical set of Pods and a policy by which to access them.
#Service can be exposed in different ways by specifying a type in the serviceSpec. StatefulSet currently requires a Headless Service to control the domain of its Pods, directly reach each Pod with stable DNS entries.
#By specifying “None” for the clusterIP, you can create Headless Service.

# Create 2 mysql services
cat << EoF > mysql-services.yaml
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  namespace: mysql
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  clusterIP: None
  selector:
    app: mysql
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the leader: mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  namespace: mysql
  name: mysql-read
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  selector:
    app: mysql
EoF

# Apply mysql-service
kubectl create -f mysql-services.yaml

# Cleanup
rm mysql-services.yaml