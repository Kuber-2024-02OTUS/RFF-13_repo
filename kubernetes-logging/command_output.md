### kubectl get node -o wide --show-labels

```plain
NAME                        STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME     LABELS
cl1qd6m81k72dk3u4sv4-ereg   Ready    <none>   38m   v1.29.1   10.129.0.3    84.201.141.224   Ubuntu 20.04.6 LTS   5.4.0-174-generic   containerd://1.6.28   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=standard-v3,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/zone=ru-central1-b,kubernetes.io/arch=amd64,kubernetes.io/hostname=cl1qd6m81k72dk3u4sv4-ereg,kubernetes.io/os=linux,node.kubernetes.io/instance-type=standard-v3,node.kubernetes.io/kube-proxy-ds-ready=true,node.kubernetes.io/masq-agent-ds-ready=true,node.kubernetes.io/node-problem-detector-ds-ready=true,topology.kubernetes.io/zone=ru-central1-b,yandex.cloud/node-group-id=catgav3lsieqnhrn2a0f,yandex.cloud/pci-topology=k8s,yandex.cloud/preemptible=false
cl1r15d5nku01d90c062-ezyt   Ready    <none>   50m   v1.29.1   10.129.0.25   158.160.89.32    Ubuntu 20.04.6 LTS   5.4.0-174-generic   containerd://1.6.28   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=standard-v3,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/zone=ru-central1-b,kubernetes.io/arch=amd64,kubernetes.io/hostname=cl1r15d5nku01d90c062-ezyt,kubernetes.io/os=linux,node.kubernetes.io/instance-type=standard-v3,node.kubernetes.io/kube-proxy-ds-ready=true,node.kubernetes.io/masq-agent-ds-ready=true,node.kubernetes.io/node-problem-detector-ds-ready=true,topology.kubernetes.io/zone=ru-central1-b,yandex.cloud/node-group-id=cat89aavvivkcvh7lg8o,yandex.cloud/pci-topology=k8s,yandex.cloud/preemptible=false
```

### kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

```plain
NAME                        TAINTS
cl1qd6m81k72dk3u4sv4-ereg   [map[effect:NoSchedule key:node-role value:infra]]
cl1r15d5nku01d90c062-ezyt   <none>
```
