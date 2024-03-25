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

## Команды для домашних работ

### ДЗ№ 4

Запуск домашнего задания:
```bash
minikube start
minikube addons enable ingress
kubectl label nodes minikube homework=true
kubectl apply -f namespace.yaml -f cm.yaml -f configmap.yaml -f deployment.yaml -f service.yaml -f ingress.yaml -f pvc.yaml

minikube service list
```

Проверка работоспособности домашнего задания:
```bash
curl http://homework.otus/homepage
curl http://homework.otus/conf/color
kubectl get po -n homework
```

### ДЗ№ 5

```bash
kubectl apply -f clusterrole_metrics.yaml -f sa_monitoring.yaml -f rb_monitoring.yaml
```

