#!/bin/zsh

# simulate MySQL as being unresponsive by following command
kubectl -n mysql exec mysql-1 -c mysql -- mv /usr/bin/mysql /usr/bin/mysql.off

# Verify that container is not responsive
kubectl -n mysql get pod mysql-1

# Revert back to original state
kubectl -n mysql exec mysql-1 -c mysql -- mv /usr/bin/mysql.off /usr/bin/mysql

# Verify that container is responsive again
kubectl -n mysql get pod mysql-1

# Delete fail pod
kubectl -n mysql delete pod mysql-1

# Watch stateful set brings back the pod
kubectl -n mysql get pod mysql-1 -w

# Scale stateful set to 3 replicas
kubectl -n mysql scale statefulset mysql --replicas=3

# Watch until rollout
kubectl -n mysql rollout status statefulset mysql

# Verify if the newly deployed follower have the same data
kubectl -n mysql run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
 mysql -h mysql-2.mysql -e "SELECT * FROM test.messages"

# Scale down replica to 2
kubectl -n mysql  scale statefulset mysql --replicas=2

# Delete pvc
kubectl -n mysql delete pvc data-mysql-2
