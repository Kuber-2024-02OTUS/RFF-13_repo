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

Для запуска команды применить все yaml-файлы.

```bash
kubectl apply -f clusterrole_metrics.yaml -f sa_monitoring.yaml -f rb_monitoring.yaml
kubectl apply -f sa_cd.yaml -f rb_cd.yaml
```

Создание токена для сервисного аккаунта cd с временем действия 1 день:
```bash
kubectl create token cd --namespace homework --duration 1440m
```

Запуск kubectl со своим конфигурационным файлом:
```bash
export KUBECONFIG=/home/user/homework-5/kubeconfig
kubectl config get-contexts
```

Использование API:
```bash
curl --cacert /home/user/.minikube/ca.crt --header "Authorization: Bearer $TOKEN" -X GET https://192.168.49.2:8443/metrics -o metrics.html
wget --ca-certificate /home/user/.minikube/ca.crt --header "Authorization: Bearer $TOKEN" -X GET https://192.168.49.2:8443/metrics -O metrics.html
```

Проверка работоспособности домашнего задания:
```bash
curl http://homework.otus/homepage
curl http://homework.otus/conf/color
curl http://homework.otus/metrics.html
kubectl get po -n homework
```

### ДЗ№ 6

#### Подготовка рабочего окружения

[Установка Helm](https://helm.sh/docs/intro/install/):

```bash
wget https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz
tar -zxvf helm-v3.14.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm-v3.14.3-linux-amd64.tar.gz linux-amd64

helm help
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Проверка корректности чарта и установка:
```bash
helm lint . --with-subcharts
helm install . --dry-run --generate-name -n homework
helm install . --generate-name -n homework --create-namespace

helm list --all --all-namespaces
```

#### Kafka

Установка helmfile:
```bash
wget https://github.com/helmfile/helmfile/releases/download/v0.163.1/helmfile_0.163.1_linux_amd64.tar.gz
tar -xzf helmfile_0.163.1_linux_amd64.tar.gz
mv helmfile /usr/bin/
rm -f LICENSE README-zh_CN.md README.md helmfile_0.163.1_linux_amd64.tar.gz
```

Применение helmfile:
```bash
helmfile init
helmfile apply
```

### ДЗ№ 7

#### Задание

* Необходимо создать кастомный образ nginx, отдающий свои метрики на определенном endpoint ( пример из офф документации в разделе ссылок)
* Установить в кластер Prometheus-operator любым удобным вам способом (рекомендуется ставить или по ссылке из офф документации, либо через helm-чарт)
* Создать deployment запускающий ваш кастомный nginx образ и service для него
* Настроить запуск nginx prometheus exporter (отдельным подом или в составе пода с nginx – не принципиально) и сконфигурировать его для сбора метрик с nginx
* Создать манифест serviceMonitor, описывающий сбор метрик с подов, которые вы создали

#### Выполнение заданий

##### Настройка Nginx

Запуск домашнего задания:
```bash
minikube start
minikube addons enable ingress
kubectl apply -f namespace.yaml -f configmap.yaml -f deployment.yaml -f service.yaml -f ingress.yaml -f service-monitor.yaml

minikube service list
```

Проверка работоспособности Nginx (добавить в /etc/hosts соответствующую запись):
```bash
kubectl get po -n homework

curl http://homework.otus/homepage
```

Удаление всех ресурсов из namespace:
```bash
kubectl delete all --all -n homework
```

##### Установка Prometheus-operator

В соответствии с [официальной документацией](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md):

```bash
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -

kubectl wait --for=condition=Ready pods -l  app.kubernetes.io/name=prometheus-operator -n default
```

### ДЗ№ 8

Managed Service for Kubernetes в Yandex.Cloud был создан через [веб-интерфейс](https://console.yandex.cloud/). Узлы были созданы через: Управление узлами --> Создать группу узлов.

Для подключения к кластеру необходимо создать конфигурационный файл. Это делается через утилиту `yc`: [Начало работы с Managed Service for Kubernetes](https://yandex.cloud/ru/docs/managed-kubernetes/quickstart?from=int-console-help-center-or-nav).

S3 Backet создан через [веб-интерфейс](https://console.yandex.cloud/). Про сервисный аккаунт можно прочитать [тут](https://yandex.cloud/ru/docs/storage/s3/). Список ролей [тут](https://yandex.cloud/ru/docs/iam/roles-reference) (storage.uploader, storage.viewer).

Назначить метку infra-ноде:
```bash
kubectl label nodes cl1qd6m81k72dk3u4sv4-ereg role=infra
# Проверить результат
kubectl get nodes --show-labels
# Либо
kubectl describe nodes
```

Установка [Loki](https://yandex.cloud/ru/docs/managed-kubernetes/operations/applications/loki#helm-install):
```bash
export HELM_EXPERIMENTAL_OCI=1 && \
helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/grafana/loki/chart/loki \
  --version 1.1.2 \
  --untar

# В loki/charts/loki-distributed/values.yaml поправить значения
# В loki/charts/promtail/values.yaml поправить значения
# Установить чарт
helm upgrade --install \
  --namespace logging \
  --create-namespace \
  --set loki-distributed.loki.storageConfig.aws.bucketnames=loki-logs-course \
  --set loki-distributed.serviceaccountawskeyvalue_generated.accessKeyID=YCAJEJkZG0yT19OE_oOVyGpH1 \
  --set loki-distributed.serviceaccountawskeyvalue_generated.secretAccessKey=YCO8ItsmqK_tRAwpgPKAmfn6g8zwJkZLgyix4Zmc \
  loki ./loki/

# Проверить, что loki установлен на нужные ноды
kubectl get po -n logging -o wide
```

>В файле `values.yaml` указаны значения, которые нужно перенести в loki/charts/loki-distributed/values.yaml.

Установка Grafana
```bash
helm plugin install https://github.com/databus23/helm-diff
helm plugin list

#helm repo add grafana https://grafana.github.io/helm-charts
#helm install --values values.yaml loki grafana/loki

cd grafana
helmfile apply

# Check installation
kubectl get po --namespace monitoring -o wide

# Get your 'admin' user password by running
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
# grafana.monitoring.svc.cluster.local
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 3000
```
