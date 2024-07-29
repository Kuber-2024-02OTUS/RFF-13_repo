#!/bin/bash
# Upgrading control plane nodes
MASTER_IP=$(yc compute instance list | grep 'k8s-node-master' | awk -F'|' '{print $6}' | tr -d ' ')

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -o ServerAliveInterval=30 yc-user@$MASTER_IP 'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring-30.gpg; \
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring-30.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF
    sudo apt-mark unhold kubeadm; \
    sudo apt-get update; \
    sudo apt-get install -y kubeadm="1.30.3-*"; \
    sudo apt-mark hold kubeadm
    kubeadm version; \
    sudo kubeadm upgrade plan; \
    sudo kubeadm upgrade apply v1.30.3 -f; \
    kubectl drain $HOSTNAME --ignore-daemonsets; \
    sudo apt-mark unhold kubelet kubectl; \
    sudo apt-get install -y kubelet="1.30.3-*" kubectl="1.30.3-*"; \
    sudo apt-mark hold kubelet kubectl; \
    sudo systemctl daemon-reload; \
    sudo systemctl restart kubelet; \
    kubectl uncordon $HOSTNAME;
'

