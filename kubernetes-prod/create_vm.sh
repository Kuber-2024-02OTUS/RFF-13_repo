#!/bin/bash
export FOLDER=$(yc config get folder-id)
export ZONE=ru-central1-a
export SUBNET=default-ru-central1-a

# Create master
yc compute instance create \
  --folder-id $FOLDER \
  --name k8s-node-master \
  --description "k8s cluster" \
  --hostname master-1 \
  --zone $ZONE \
  --platform standard-v2 \
  --create-boot-disk image-family=ubuntu-2404-lts-oslogin,size=20,type=network-hdd \
  --image-folder-id standard-images \
  --memory 8 \
  --cores 2 \
  --core-fraction 20 \
  --preemptible \
  --network-settings type=standard \
  --network-interface subnet-name=$SUBNET,nat-ip-version=ipv4 \
  --ssh-key ~/.ssh/id_rsa.pub \
  --metadata serial-port-enable=1 \
  --async

# Create workers
for i in 1 2 3
do
  yc compute instance create \
    --folder-id $FOLDER \
    --name k8s-node-worker-$i \
    --description "k8s cluster" \
    --hostname worker-$i \
    --zone $ZONE \
    --platform standard-v2 \
    --create-boot-disk image-family=ubuntu-2404-lts-oslogin,size=20,type=network-hdd \
    --image-folder-id standard-images \
    --memory 8 \
    --cores 2 \
    --core-fraction 20 \
    --preemptible \
    --network-settings type=standard \
    --network-interface subnet-name=$SUBNET,nat-ip-version=ipv4 \
    --ssh-key ~/.ssh/id_rsa.pub \
    --metadata serial-port-enable=1 \
    --async
done
