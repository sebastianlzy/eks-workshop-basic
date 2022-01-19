# Objective for this module

In this chapter, we will review how to deploy a MySQL database using StatefulSet and Amazon Elastic Block Store (EBS) as PersistentVolume. The example is a MySQL single leader topology with a follower running asynchronous replication leveraging on dynamic provisioning.

# What is statefulset?

StatefulSet manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods, suitable for applications that require one or more of the following.

1. Stable, unique network identifiers
2. Stable, persistent storage
3. Ordered, graceful deployment and scaling
4. Ordered, automated rolling updates

# What is Container Storage Interface (CSI)?

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Container Orchestration Systems (COs) like Kubernetes.

By using CSI, third-party storage providers can write and deploy plugins exposing new storage systems in Kubernetes without ever having to touch the core Kubernetes code.

The Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver provides a CSI interface that allows Amazon Elastic Kubernetes Service (Amazon EKS) clusters to manage the lifecycle of Amazon EBS volumes for persistent volumes.