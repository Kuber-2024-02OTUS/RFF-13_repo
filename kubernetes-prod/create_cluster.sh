#!/bin/bash
# Configure master-node
MASTER_IP=$(yc compute instance list | grep 'k8s-node-master' | awk -F'|' '{print $6}' | tr -d ' ')
KUBEADM_INIT_TEXT=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ServerAliveInterval=30 yc-user@$MASTER_IP 'sudo kubeadm init --pod-network-cidr=10.244.0.0/16')
KUBEADM_JOIN_CMD=$(echo $KUBEADM_INIT_TEXT | grep -oE 'kubeadm join (.)*' | tr -d '\')

echo $KUBEADM_JOIN_CMD > kubeadm_join.cmd

# Copy config
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ServerAliveInterval=30 yc-user@$MASTER_IP 'mkdir -p $HOME/.kube; \
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; \
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
'

# Install Flannel
scp -o StrictHostKeyChecking=no kube-flannel.yml yc-user@$MASTER_IP:/tmp/kube-flannel.yml
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ServerAliveInterval=30 yc-user@$MASTER_IP 'kubectl apply -f /tmp/kube-flannel.yml'
