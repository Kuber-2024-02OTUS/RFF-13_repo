# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2024-02" 

## Примеры команд

### minikube

Включить Ingress в minikube:
```bash
minikube addons enable ingress
```

Получть ссылку, по которой доступен Ingress:
```bash
minikube service list
```

Присвоить метку ноде:
```bash
kubectl label nodes minikube homework=true
```
