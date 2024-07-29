#!/bin/bash
# Upgrading control plane nodes
MASTER_IP=$(yc compute instance list | grep 'k8s-node-master' | awk -F'|' '{print $6}' | tr -d ' ')



# Upgrading worker nodes
ADDRESSES=$(yc compute instance list | grep k8s-node-worker | awk -F'|' '{print $6}' | tr -d ' ')
for ADDRESS in $ADDRESSES
do
  ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 yc-user@$ADDRESS 'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring-30.gpg; \
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring-30.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF
    sudo apt-mark unhold kubeadm; \
    sudo apt-get update; \
    sudo apt-get install -y kubeadm="1.30.3-*"; \
    sudo apt-mark hold kubeadm; \
    sudo kubeadm upgrade node; \
    kubectl drain $HOSTNAME --ignore-daemonsets; \
    sudo apt-mark unhold kubelet kubectl; \
    sudo apt-get install -y kubelet="1.30.3-*" kubectl="1.30.3-*"; \
    sudo apt-mark hold kubelet kubectl; \
    sudo systemctl daemon-reload; \
    sudo systemctl restart kubelet; \
    kubectl uncordon $HOSTNAME;
'
done
