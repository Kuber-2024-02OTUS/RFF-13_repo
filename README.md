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

Установка Promtail, Loki, Grafana:
```bash
cd loki && helmfile apply; cd ..
cd promtail && helmfile apply; cd ..
cd grafana && helmfile apply; cd ..
```

Проверить, что поды запущены:
```bash
kubectl get po --namespace monitoring -o wide
```

Получение пароля от Grafana
```bash
# Get your 'admin' user password by running
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
# grafana.monitoring.svc.cluster.local
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 3000
```

### ДЗ№ 9

#### Задание

* Создать манифест объекта CustomResourceDefinition со следующими параметрами:
  * Объект уровня namespace
  * Api group – otus.homework
  * Kind – MySQL
  * Plural name – mysqls
  * Версия – v1
* Объект должен иметь следующие обязательные атрибуты и правила их валидации(все поля строковые):
  * Image – определяет docker-образ для создания
  * Database – имя базы данных
  * Password – пароль от БД
  * Storage_size – размер хранилища под базу
*Создать манифесты ServiceAccount, ClusterRole и ClusterRoleBinding, описывающий сервис аккаунт с полными правами на доступ к api серверу
* Создать манифест deployment для оператора, указав созданный ранее ServiceAccount и образ roflmaoinmysoul/mysql-operator:1.0.0
* Создать манифест кастомного объекта kind: MySQL валидный для применения (см. атрибуты CRD созданного ранее)
* Применить все манифесты и убедиться, что CRD создался, оператор работает и при создании кастомного ресурса типа MySQL создает Deployment с указанным образом mysql, service для него, PV и PVC. При удалении объекта типа MySQL удаляются все созданные для него ресурсы

#### Задание со *

* Изменить манифест ClusterRole, описав в нем минимальный набор прав доступа необходимые для нашего CRD и убедиться что функциональность не пострадала
  * Управление сами ресурсом CRD
  * Создание и удаление ресурсов типа Service, PV, PVC

#### Задание с **

* Создать свой оператор, который будет реализовывать следующий функционал:
  * При создании в кластере объектов с типом MySQL (mysqls.otus.homework/v1) будет создавать deployment с заданным образом mysql, сервис типа ClusterIP, PV и PVC заданного размера
  * При удалении объекта с типом MySQL будет удалять ранее созданные ресурсы

#### Запуск проекта

```bash
kubectl apply -f cr.yaml -f sa.yaml -f crb.yaml
kubectl apply -f crd.yaml

cd mysql-operator-shell/ && ./build.sh && cd ..

kubectl apply -f deployment-operator-shell.yaml -f mysql.yaml
```

#### Проверка работоспособности

```bash
# Просмотр созданных ресурсов
kubectl get pvc,pv,svc,deploy,pods,mysqls,sa,crd

# Проверка запуска MySQL
kubectl port-forward $(kubectl get pods | grep mysql-crd | awk '{print $1}') 3306:3306
telnet 127.0.0.1 3306
mysql -h 127.0.0.1 -P 3306 -u root -psecret
```

#### Полезные ссылки

[Собственные CRD в Kubernetes](https://habr.com/ru/companies/otus/articles/787790/)
[Представляем shell-operator: создавать операторы для Kubernetes стало ещё проще](https://habr.com/ru/companies/flant/articles/447442/)

### ДЗ№ 10

#### Задание

* Данное задание будет выполняться в managed k8s в Yandex cloud
* Разверните managed Kubernetes cluster в Yandex cloud любым
удобным вам способом
* Для кластера создайте 2 пула нод:
  * Для рабочей нагрузки (можно 1 ноду)
  * Для инфраструктурных сервисов (также хватит и 1 ноды)
* Для инфраструктурной ноды/нод добавьте taint, запрещающий на нее планирование подов с посторонней нагрузкой - node-role=infra:NoSchedule
* Установите в кластер ArgoCD с помощью Helm-чарта
  * Необходимо сконфигурировать параметры установки так, чтобы компоненты argoCD устанавливались исключительно на infra-ноды (добавить соответствующий toleration для обхода taint, а также nodeSelector или nodeAffinity на ваш выбор, для планирования подов только на заданные ноды)
  * Приложите к ДЗ values.yaml конфигурации установки ArgoCD и команду самой установки чарта
* Создайте project с именем Otus
  * В качестве Source-репозитория укажите ваш репозиторий с ДЗ курса
  * В качестве Destination должен быть указан ваш кластер, в который установлен ArgoCD
  * Приложите манифест, описывающий project к ДЗ
* Создайте приложение ArgoCD
  * В качестве репозитория укажите ваше приложение из ДЗ kubernetes-networks
  * Sync policy – manual
  * Namespace - homework
  * Проект – Otus. Убедитесь, что есть необходимые настройки, для создания и установки в namespace, который описан в ДЗ kubernetes-networks
  * Убедитесь, что nodeSelector позволяет установить приложение на одну из нод кластера
  * Приложите манифест, описывающий установку приложения к результатам ДЗ
* Создайте приложение ArgoCD
  * В качестве репозитория укажите ваше приложение из ДЗ kubernetes-templating
  * Укажите директорию, в которой находится ваш helm-чарт, который вы разрабатывали самостоятельно
  * SyncPolicy – Auto, AutoHeal – true, Prune – true.
  * Проект – Otus.
  * Namespace – HomeworkHelm. Убедитесь, что установка чарта будет остуществляться в отличный от первого приложения namespace.
  * Параметр, задающий количество реплик запускаемого приложения должен переопределяться в конфигурации
  * Приложите манифест, описывающий установку приложения к результатам ДЗ

#### Выполнение задания

Managed Service for Kubernetes в Yandex.Cloud был создан и настроен, как в ДЗ№ 8.

Установка [ArgoCD](https://github.com/argoproj/argo-helm/tree/main) с помощью Helm-чарта:
```bash
cd argocd && helmfile apply; cd ..
```

Проверить, что поды запущены:
```bash
kubectl get po --namespace default -o wide
```

Получение пароля от аккаунта администратора (admin):
```bash
kubectl exec -it service/argocd-server argocd admin initial-password
```

Получение доступа к web-интерфейсу ArgoCD, который буде доступен [здесь](https://127.0.0.1:8090/login):
```bash
kubectl port-forward service/argocd-server 8090:80
```

Выполнение команд argocd в консоли:
```bash
kubectl exec -it service/argocd-server /bin/bash
argocd login localhost:8080
# Список проектов
argocd proj list
# Подробная информация о проекте в yaml-формате
argocd proj get otus -o yaml
```
