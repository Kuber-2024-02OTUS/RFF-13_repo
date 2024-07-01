#!/bin/bash

# Get VM IPs
ADDRESSES=$(yc compute instance list --format=json | jq -r '.[].network_interfaces' | grep '        "address' | awk '{print $2}' | tr -d '",')

# Check if SSH available
for ADDRESS in $ADDRESSES
do
  CHECK_RESULT=$(ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 yc-user@$ADDRESS echo ok 2>&1)
  if [[ "$CHECK_RESULT" == "ok" ]]; then
    echo "Connection to $ADDRESS is $CHECK_RESULT"
  else
    echo "Connection error to $ADDRESS"
    exit
  fi
done

# Disable swap
for ADDRESS in $ADDRESSES
do
  ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=5 yc-user@$ADDRESS "sudo swapoff -a"
done

# Install containerd
for ADDRESS in $ADDRESSES
do
  ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=5 yc-user@$ADDRESS "sudo apt-get update; \
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; \
    echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; \
    sudo apt-get update; \
    sudo apt-get install -y containerd.io; \
    sudo containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/g' | sudo tee /etc/containerd/config.toml; \
    sudo systemctl restart containerd; \
    rm -f /etc/modules-load.d/containerd.conf; \
    cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
    sudo modprobe overlay; \
    sudo modprobe br_netfilter; \
    rm -f /etc/sysctl.d/99-kubernetes-cri.conf; \
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
    sudo sysctl --system
    "
done

# Install kubelet, kubeadm, kubectl
for ADDRESS in $ADDRESSES
do
  ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=5 yc-user@$ADDRESS "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg; \
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
EOF
    sudo apt-get update; \
    sudo apt-get install -y kubelet kubeadm kubectl; \
    sudo apt-mark hold kubelet kubeadm kubectl
    "
done
