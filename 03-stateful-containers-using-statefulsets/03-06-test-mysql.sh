#!/bin/zsh

# Send data to leader, mysql-0.mysql
kubectl -n mysql run mysql-client --image=mysql:5.7 -i --rm --restart=Never --\
  mysql -h mysql-0.mysql <<EOF
CREATE DATABASE test;
CREATE TABLE test.messages (message VARCHAR(250));
INSERT INTO test.messages VALUES ('hello, from mysql-client');
EOF

# test follower if it received the data, mysql-read
kubectl -n mysql run mysql-client --image=mysql:5.7 -it --rm --restart=Never --\
  mysql -h mysql-read -e "SELECT * FROM test.messages"

# To test load balancing across follower
kubectl -n mysql run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
   bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id,NOW()'; done"

# Each MySQL instance is assigned a unique identifier, and it can be retrieved using @@server_id.
# Output
#+-------------+---------------------+
#| @@server_id | NOW()               |
#+-------------+---------------------+
#|         101 | 2021-02-21 19:17:52 |
#+-------------+---------------------+
#+-------------+---------------------+
#| @@server_id | NOW()               |
#+-------------+---------------------+
#|         101 | 2021-02-21 19:17:53 |
#+-------------+---------------------+
#+-------------+---------------------+
#| @@server_id | NOW()               |
#+-------------+---------------------+
#|         100 | 2021-02-21 19:17:54 |
#+-------------+---------------------+
#+-------------+---------------------+
#| @@server_id | NOW()               |
#+-------------+---------------------+
#|         100 | 2021-02-21 19:17:55 |
#+-------------+---------------------+