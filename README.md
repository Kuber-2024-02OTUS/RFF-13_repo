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

Чтобы приложение kubernetes-networks развернулось, необходимо присвоить ноде метку:
```bash
kubectl create ns homework
kubectl label nodes cl1r15d5nku01d90c062-ezyt homework=true
```

### ДЗ№ 11

#### Задание

* Данное задание будет выполняться в managed k8s в Yandex cloud
* Разверните managed Kubernetes cluster в Yandex cloud любым удобным вам способом. Создайте 3 ноды для кластера
* В namespace consul установите consul из helm-чарта https://github.com/hashicorp/consul-k8s.git с параметрами 3 реплики для сервера. Приложите команду установки чарта и файл с переменными к результатам ДЗ.
* В namespace vault установите hashicorp vault из helm-чарта https://github.com/hashicorp/vault-helm.git
  * Сконфигурируйте установку для использования ранее установленного consul в HA режиме
  * Приложите команду установки чарта и файл с переменными к результатам ДЗ.
* Выполните инициализацию vault и распечатайте с помощью полученного unseal key все поды хранилища
* Создайте хранилище секретов otus/ с Secret Engine KV, а в нем секрет otus/cred, содержащий username='otus' password='asajkjkahs’
* В namespace vault создайте serviceAccount с именем vault-auth и ClusterRoleBinding для него с ролью system:auth-delegator. Приложите получившиеся манифесты к результатам ДЗ
* В Vault включите авторизацию auth/kubernetes и сконфигурируйте ее используя токен и сертификат ранее созданного ServiceAccount
* Создайте и примените политику otus-policy для секретов /otus/cred с capabilities = [“read”, “list”]. Файл .hcl с политикой приложите к результатам ДЗ
* Создайте роль auth/kubernetes/role/otus в vault с использованием ServiceAccount vault-auth из namespace Vault и политикой otus-policy
* Установите External Secrets Operator из helm-чарта в namespace vault. Команду установки чарта и файл с переменными, если вы их используете приложите к результатам ДЗ
* Создайте и примените манифест crd объекта SecretStore в namespace vault, сконфигурированный для доступа к KV секретам Vault с использованием ранее созданной роли otus и сервис аккаунта vault-auth. Убедитесь, что созданный SecretStore успешно подключился к vault. Получившийся манифест приложите к результатам ДЗ.
* Создайте и примените манифест crd объекта ExternalSecret с следующими параметрами:
  * ns – vault
  * SecretStore – созданный на прошлом шаге
  * Target.name = otus-cred
  * Получает значения KV секрета /otus/cred из vault и отображает их в два ключа – username и password соответственно
* Убедитесь, что после применения ExternalSecret будет создан Secret в ns vault с именем otus-cred и хранящий в себе 2 ключа username и password, со значениями, которые были сохранены ранее в vault. Добавьте манифест объекта ExternalSecret к результатам ДЗ.

#### Выполнение задания

Создать ёще одну ноду в кластере.

Убрать taint:
```bash
kubectl taint nodes cl1qd6m81k72dk3u4sv4-ereg node-role=infra:NoSchedule-
```

Установить consul и vault (через VPN):
```bash
cd consul && helmfile apply; cd ..
cd vault && helmfile apply; cd ..
```

При возникновении ошибки запуска, если ноды были оффлайн более недели, смотри [тут](https://www.ibm.com/support/pages/consul-pod-fails-start).

Далее необходимо выполнить инициализацию vault:
```bash
kubectl exec -it vault-0 -n vault /bin/sh
vault operator init --key-shares=1 --key-threshold=1
vault operator unseal
```

Unseal Key и Initial Root Token нужно сохранить.

На всех остальных подах vault тоже нужно выполнить команду `vault operator unseal`, введя Unseal Key.

Чтобы зайти в веб-интерфейс, нужно прокинуть порт:
```bash
kubectl port-forward vault-0 -n vault 8200:8200
```

Далее в веб-интерфейсе делаем, что требуется по заданию.
```bash
vault secrets enable -path otus/ kv-v2
vault kv put otus/cred 'username=otus'
vault kv patch otus/cred 'password=asajkjkahs'
```

Для создания сервисного аккаунта и роли:
```bash
kubectl apply -f sa.yaml -f crb.yaml
```

Включение аутентификации через k8s (зайти на vault-0):
```bash
vault auth enable kubernetes

vault write auth/kubernetes/config \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

~~Создание политики (зайти на vault-0)~~:
```bash
vault login
vault policy write otus-policy - <<EOH
path "otus/cred" {
  capabilities = ["read", "list"]
}
EOH
```

Команда выше не заработает, так как нужно явно указывать data:
```bash
vault policy write otus-policy - <<EOH
path "otus/data/cred" {
  capabilities = ["read", "list"]
}
EOH
```

Создание роли:
```bash
vault write auth/kubernetes/role/otus \
bound_service_account_names=vault-auth \
bound_service_account_namespaces=vault \
policies=otus-policy \
ttl=72h

vault read auth/kubernetes/role/otus
```

Установка [External Secrets Operator](https://external-secrets.io/latest/):
```bash
cd external-secrets && helmfile apply; cd ..
```

Создание [SecretStore](https://external-secrets.io/v0.5.2/api-secretstore/):
```bash
kubectl apply -f SecretStore.yaml
```

Создание [ExternalSecret](https://external-secrets.io/v0.5.2/api-externalsecret/):
```bash
kubectl apply -f ExternalSecret.yaml
```

### ДЗ№ 12

#### Задание

* Данное задание будет выполняться в managed k8s в Yandex cloud
* Разверните managed Kubernetes cluster в Yandex cloud любым удобным вам способом, конфигурация нод не имеет значения
* Создайте бакет в s3 object storage Yandex cloud. Он будет использоваться для монтирования volume внутрь подов.
* Создайте ServiceAccount для доступа к бакету с правами, которые необходимы согласно инструкции YC и сгенерируйте ключи доступа.
* Создайте secret c ключами для доступа к Object Storage и приложите манифест для проверки ДЗ
* Создайте storageClass описывающий класс хранилища и приложите манифест для проверки ДЗ
* Установите CSI driver из репозитория
* Создайте манифест PVC, использующий для хранения созданный вами storageClass с механизмом autoProvisioning и приложите его для проверки ДЗ
* Создайте манифест pod или deployment, использующий созданный ранее PVC в качестве volume и монтирующий его в контейнер пода в произвольную точку монтирования и приложите манифест для проверки ДЗ.
* Под в процессе работы должен производить запись в примонтированную директорию. Убедитесь, что файлы действительно сохраняются в ObjectStorage.

#### Выполнение задания

При настройке S3, не забудьте добавить пользователя с нужными правами в разделе Права доступа.

Почти все шаги ДЗ можно посмотреть [тут](https://github.com/yandex-cloud/k8s-csi-s3).

Про создание secret можно посмотреть [тут](https://github.com/aws-samples/machine-learning-using-k8s/blob/master/docs/aws-creds-secret.md), создать командой:
```bash
kubectl apply -f secret.yaml
```

Установка CSI driver из [репозитория](https://github.com/yandex-cloud/k8s-csi-s3):
```bash
cd deploy-kubernetes
kubectl create -f provisioner.yaml
kubectl create -f driver.yaml
kubectl create -f csi-s3.yaml
cd ..
```

Создание StorageClass (отредактировать файл в соответствии с [этим разделом](https://github.com/yandex-cloud/k8s-csi-s3?tab=readme-ov-file#bucket)):
```bash
kubectl create -f storageClass.yaml
```

Создание PVC:
```bash
kubectl create -f pvc.yaml
```

Проверка того, что PVC забиндился:
```bash
kubectl get pvc csi-s3-pvc
```

Вывод должен быть примерно таким:
```plain
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             VOLUMEATTRIBUTESCLASS   AGE
csi-s3-pvc   Bound    pvc-13d8632f-04fb-413a-a4ca-45aba3965010   5Gi        RWX            csi-s3-existing-bucket   <unset>                 9m1s
```

Запуск тестового пода:
```bash
kubectl apply -f pod.yaml
```

Проверка того, что файлы успешно создаются:
```bash
kubectl exec -ti csi-s3-test-nginx bash
mount | grep fuse
# loki-logs-course on /usr/share/nginx/html/s3 type fuse.geesefs (rw,nosuid,nodev,relatime,user_id=65534,group_id=0,default_permissions,allow_other)
touch /usr/share/nginx/html/s3/hello_world
```

Результат создания файла можно посмотреть в веб-интерфейсе бакета.

Траблшутинг ExternalSecret:
```bash
kubectl logs external-secrets-c5c4df7cf-llrfg --follow -n vault
```

Проверка ExternalSecret на работоспособность:
```bash
kubectl get secrets -n vault
```

### ДЗ№ 13

#### Задание

* Данное задание можно выполнять как в minikube так и в managed k8s в Yandex cloud
* Создайте манифест, описывающий pod с distroless образом для создания контейнера, например kyos0109/nginx-distroless и примените его в кластере. Приложите манифест к результатам ДЗ.
* С помощью команды kubectl debug создайте эфемерный контейнер для отладки этого пода. Отладочный контейнер должен иметь доступ к пространству имен pid для основного контейнера пода.
* Получите доступ к файловой системе отлаживаемого контейнера из эфемерного. Приложите к результатам ДЗ вывод команды ls –la для директории /etc/nginx
* Запустите в отладочном контейнере команду tcpdump -nn -i any -e port 80 (или другой порт, если у вас приложение на нем)
* Выполните несколько сетевых обращений к nginx в отлаживаемом поде любым удобным вам способом. Убедитесь что tcpdump отображает сетевые пакеты этих подключений. Приложите результат работы tcpdump к результатам ДЗ.
* С помощью kubectl debug создайте отладочный под для ноды, на которой запущен ваш под с distroless nginx
* Получите доступ к файловой системе ноды, и затем доступ к логам пода с distrolles nginx. Приложите сами логи, и команду их получения к результатам ДЗ.

#### Задание со *

* Выполните команду strace для корневого процесса nginx в рассматриваемом ранее поде. Опишите в результатах ДЗ какие операции необходимо сделать, для успешного выполнения команды, и также приложите ее вывод к результатам ДЗ.

#### Выполнение задания

Задание будет выполняться в [minikube](https://www.linuxtechi.com/how-to-install-minikube-on-debian/).

Создаём и применяем манифест для пода:
```bash
kubectl apply -f pod.yaml
```

Проверяем, что веб-сервер действительно работает. Для этого прокидываем порт:
```bash
# kubectl port-forward POD_NAME LOCAL_PORT:REMOTE_POD_PORT
kubectl port-forward webserver 8080:80
```

И смотрим [тут](http://127.0.0.1:8080). Если видим "Welcome to nginx!", значит всё хорошо.

Создание отладочного контейнера с доступом к PID пода:
```bash
kubectl debug -it -c debugger --image=busybox:latest --target=webserver webserver
```

Проверка, что доступ к PID есть:
```palin
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
    7 101       0:00 nginx: worker process
   15 root      0:00 sh
   26 root      0:00 ps aux
```

Проверка доступа к файловой системе пода:
```palin
/ # ls -la /proc/$(pgrep nginx | head -n1)/root/etc/nginx/
total 48
drwxr-xr-x    3 root     root          4096 Oct  5  2020 .
drwxr-xr-x    1 root     root          4096 Jun 25 11:45 ..
drwxr-xr-x    2 root     root          4096 Oct  5  2020 conf.d
-rw-r--r--    1 root     root          1007 Apr 21  2020 fastcgi_params
-rw-r--r--    1 root     root          2837 Apr 21  2020 koi-utf
-rw-r--r--    1 root     root          2223 Apr 21  2020 koi-win
-rw-r--r--    1 root     root          5231 Apr 21  2020 mime.types
lrwxrwxrwx    1 root     root            22 Apr 21  2020 modules -> /usr/lib/nginx/modules
-rw-r--r--    1 root     root           643 Apr 21  2020 nginx.conf
-rw-r--r--    1 root     root           636 Apr 21  2020 scgi_params
-rw-r--r--    1 root     root           664 Apr 21  2020 uwsgi_params
-rw-r--r--    1 root     root          3610 Apr 21  2020 win-utf
```

Для запуска tcpdump используем другой образ:
```bash
kubectl debug -it -c debugger-tcpdump --image=nicolaka/netshoot:latest --target=webserver webserver
```

Результат работы команды `tcpdump -nn -i any -e port 80`:
```plain
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
12:02:04.664543 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.49744 > 127.0.0.1.80: Flags [S], seq 3083184088, win 65495, options [mss 65495,sackOK,TS val 1037395733 ecr 0,nop,wscale 7], length 0
12:02:04.664550 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.80 > 127.0.0.1.49744: Flags [S.], seq 760988333, ack 3083184089, win 65483, options [mss 65495,sackOK,TS val 1037395733 ecr 1037395733,nop,wscale 7], length 0
12:02:04.664557 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.49744 > 127.0.0.1.80: Flags [.], ack 1, win 512, options [nop,nop,TS val 1037395733 ecr 1037395733], length 0
12:02:04.664588 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 537: 127.0.0.1.49744 > 127.0.0.1.80: Flags [P.], seq 1:466, ack 1, win 512, options [nop,nop,TS val 1037395733 ecr 1037395733], length 465: HTTP: GET / HTTP/1.1
12:02:04.664590 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.49744: Flags [.], ack 466, win 508, options [nop,nop,TS val 1037395733 ecr 1037395733], length 0
12:02:04.664747 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 310: 127.0.0.1.80 > 127.0.0.1.49744: Flags [P.], seq 1:239, ack 466, win 512, options [nop,nop,TS val 1037395733 ecr 1037395733], length 238: HTTP: HTTP/1.1 200 OK
12:02:04.664756 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.49744 > 127.0.0.1.80: Flags [.], ack 239, win 511, options [nop,nop,TS val 1037395733 ecr 1037395733], length 0
12:02:04.665942 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 684: 127.0.0.1.80 > 127.0.0.1.49744: Flags [P.], seq 239:851, ack 466, win 512, options [nop,nop,TS val 1037395735 ecr 1037395733], length 612: HTTP
12:02:04.665946 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.49744 > 127.0.0.1.80: Flags [.], ack 851, win 507, options [nop,nop,TS val 1037395735 ecr 1037395735], length 0
12:02:04.676771 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 474: 127.0.0.1.49744 > 127.0.0.1.80: Flags [P.], seq 466:868, ack 851, win 512, options [nop,nop,TS val 1037395745 ecr 1037395735], length 402: HTTP: GET /favicon.ico HTTP/1.1
12:02:04.676922 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 380: 127.0.0.1.80 > 127.0.0.1.49744: Flags [P.], seq 851:1159, ack 868, win 512, options [nop,nop,TS val 1037395745 ecr 1037395745], length 308: HTTP: HTTP/1.1 404 Not Found
12:02:04.723972 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.49744 > 127.0.0.1.80: Flags [.], ack 1159, win 512, options [nop,nop,TS val 1037395793 ecr 1037395745], length 0
12:03:09.733907 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.49744: Flags [F.], seq 1159, ack 868, win 512, options [nop,nop,TS val 1037460802 ecr 1037395793], length 0
12:03:09.779981 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.49744 > 127.0.0.1.80: Flags [.], ack 1160, win 512, options [nop,nop,TS val 1037460849 ecr 1037460802], length 0
12:03:10.234543 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.49744 > 127.0.0.1.80: Flags [F.], seq 868, ack 1160, win 512, options [nop,nop,TS val 1037461303 ecr 1037460802], length 0
12:03:10.234560 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.49744: Flags [.], ack 869, win 512, options [nop,nop,TS val 1037461303 ecr 1037461303], length 0
12:03:13.363211 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.57262 > 127.0.0.1.80: Flags [S], seq 2355406827, win 65495, options [mss 65495,sackOK,TS val 1037464432 ecr 0,nop,wscale 7], length 0
12:03:13.363223 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.80 > 127.0.0.1.57262: Flags [S.], seq 4100574950, ack 2355406828, win 65483, options [mss 65495,sackOK,TS val 1037464432 ecr 1037464432,nop,wscale 7], length 0
12:03:13.363234 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.57262 > 127.0.0.1.80: Flags [.], ack 1, win 512, options [nop,nop,TS val 1037464432 ecr 1037464432], length 0
12:03:13.364178 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 543: 127.0.0.1.57262 > 127.0.0.1.80: Flags [P.], seq 1:472, ack 1, win 512, options [nop,nop,TS val 1037464433 ecr 1037464432], length 471: HTTP: GET /qwerty HTTP/1.1
12:03:13.364201 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.57262: Flags [.], ack 472, win 508, options [nop,nop,TS val 1037464433 ecr 1037464433], length 0
12:03:13.364363 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 380: 127.0.0.1.80 > 127.0.0.1.57262: Flags [P.], seq 1:309, ack 472, win 512, options [nop,nop,TS val 1037464433 ecr 1037464433], length 308: HTTP: HTTP/1.1 404 Not Found
12:03:13.364379 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.57262 > 127.0.0.1.80: Flags [.], ack 309, win 510, options [nop,nop,TS val 1037464433 ecr 1037464433], length 0
```

Отладка ноды:
```bash
kubectl debug node/minikube -it --image=busybox:latest
```

Для получения логов узнаем, куда ссылается файл:
```bash
ls -la /host/var/log/pods/default_webserver_d46df3fb-86fe-4325-9e96-69c24bf6a8bd/webserver/0.log
```

Получаем лог пода с nginx (`cat /host/var/lib/docker/containers/937ef05005f548ed33abaa63476cc9635d5c862d29f8b4201b6918594b5ef965/937ef05005f548ed33abaa63476cc9635d5c862d29f8b4201b6918594b5ef965-json.log`):
```plain
{"log":"127.0.0.1 - - [25/Jun/2024:20:02:04 +0800] \"GET / HTTP/1.1\" 200 612 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0\" \"-\"\n","stream":"stdout","t
ime":"2024-06-25T12:02:04.666106883Z"}
{"log":"127.0.0.1 - - [25/Jun/2024:20:02:04 +0800] \"GET /favicon.ico HTTP/1.1\" 404 153 \"http://127.0.0.1:8080/\" \"Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0
\" \"-\"\n","stream":"stdout","time":"2024-06-25T12:02:04.676989093Z"}
{"log":"2024/06/25 20:02:04 [error] 7#7: *1 open() \"/usr/share/nginx/html/favicon.ico\" failed (2: No such file or directory), client: 127.0.0.1, server: localhost, request: \"GET /favico
n.ico HTTP/1.1\", host: \"127.0.0.1:8080\", referrer: \"http://127.0.0.1:8080/\"\n","stream":"stderr","time":"2024-06-25T12:02:04.677008983Z"}
{"log":"2024/06/25 20:03:13 [error] 7#7: *2 open() \"/usr/share/nginx/html/qwerty\" failed (2: No such file or directory), client: 127.0.0.1, server: localhost, request: \"GET /qwerty HTTP
/1.1\", host: \"127.0.0.1:8080\"\n","stream":"stderr","time":"2024-06-25T12:03:13.364525594Z"}
{"log":"127.0.0.1 - - [25/Jun/2024:20:03:13 +0800] \"GET /qwerty HTTP/1.1\" 404 153 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0\" \"-\"\n","stream":"stdo
ut","time":"2024-06-25T12:03:13.364530849Z"}
```

Для корректной работы [strace](https://losst.pro/komanda-strace-v-linux) необходимо добавить `--profile`:
```bash
kubectl debug -it -c debugger-strace --profile=general --image=nicolaka/netshoot:latest --target=webserver webserver
```

Далее в отладочном контейнере:
```plain
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
    7 bird      0:00 nginx: worker process
  111 root      0:00 zsh
  184 root      0:00 ps aux
```

```plain
/ # strace -ff -v -p 1
strace: Process 1 attached
rt_sigsuspend([], 8
```

После выполнения команды нужно обновить страницу в браузере (не используя кеш):
```plain
/ # strace -ff -v -p 7
strace: Process 7 attached
epoll_wait(8, [{events=EPOLLIN, data={u32=2449646049, u64=139915304280545}}], 512, 56836) = 1
recvfrom(3, "GET / HTTP/1.1\r\nHost: 127.0.0.1:"..., 1024, 0, NULL, NULL) = 494
stat("/usr/share/nginx/html/index.html", {st_dev=makedev(0, 0xdb), st_ino=679805, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=612, st_atime=1587472992 /* 2020-04-21T12:43:12+0000 */, st_atime_nsec=0, st_mtime=1587472992 /* 2020-04-21T12:43:12+0000 */, st_mtime_nsec=0, st_ctime=1719314138 /* 2024-06-25T11:15:38.572776347+0000 */, st_ctime_nsec=572776347}) = 0
openat(AT_FDCWD, "/usr/share/nginx/html/index.html", O_RDONLY|O_NONBLOCK) = 11
fstat(11, {st_dev=makedev(0, 0xdb), st_ino=679805, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=612, st_atime=1587472992 /* 2020-04-21T12:43:12+0000 */, st_atime_nsec=0, st_mtime=1587472992 /* 2020-04-21T12:43:12+0000 */, st_mtime_nsec=0, st_ctime=1719314138 /* 2024-06-25T11:15:38.572776347+0000 */, st_ctime_nsec=572776347}) = 0
writev(3, [{iov_base="HTTP/1.1 200 OK\r\nServer: nginx/1"..., iov_len=238}], 1) = 238
sendfile(3, 11, [0] => [612], 612)      = 612
write(5, "127.0.0.1 - - [25/Jun/2024:21:44"..., 149) = 149
close(11)                               = 0
epoll_wait(8, [{events=EPOLLIN, data={u32=2449646049, u64=139915304280545}}], 512, 65000) = 1
recvfrom(3, "GET /favicon.ico HTTP/1.1\r\nHost:"..., 1024, 0, NULL, NULL) = 445
openat(AT_FDCWD, "/usr/share/nginx/html/favicon.ico", O_RDONLY|O_NONBLOCK) = -1 ENOENT (No such file or directory)
gettid()                                = 7
write(4, "2024/06/25 21:44:58 [error] 7#7:"..., 253) = 253
writev(3, [{iov_base="HTTP/1.1 404 Not Found\r\nServer: "..., iov_len=155}, {iov_base="<html>\r\n<head><title>404 Not Fou"..., iov_len=100}, {iov_base="<hr><center>nginx/1.18.0</center"..., iov_len=53}], 3) = 308
write(5, "127.0.0.1 - - [25/Jun/2024:21:44"..., 181) = 181
epoll_wait(8, 
```

### ДЗ№ 14

#### Задание

* Для выполнения данного задания вам потребуется создать минимум 4 виртуальных машины в YC следующей конфигурации:
  * Для master - 1 узел, 2vCPU, 8GB RAM
  * Для worker – 3 узла, 2vCPU, 8GB RAM
* Версия создаваемого кластера должна быть на одну ниже чем актуальная версия kubernetes на момент выполнения (т.е если последняя актуальная версия 1.30.x, то ставим 1.29.x)
* Выполните подготовительные работы на узлах в соответствии с инструкцией (отключить swap, включите маршрутизацию и т.д)
* Установите containerd, kubeadm, kubelet, kubectl на все ВМ
* Выполните kubeadm init на мастер-ноде
* Установите Flannel в качестве сетевого плагина
* Выполните kubeadm join на воркер нодах
* Приложите к результатам ДЗ вывод команды kubectl get nodes -o wide, показывающий статус и версию k8s всех нод кластера
* Приложите к результатам ДЗ все команды, выполненные вами как на мастер, так и на воркер нодах (можно в readme, можно в виде .sh скриптов, или иным образом как вам удобно) для возможности воспроизведения ваших действий
* Выполните обновление master ноды до последней актуальной версии k8s с помощью kubeadm
* Последовательно выведите из планирования все воркер-ноды, обновите их до последней актуальной версии и верните в планирование
* Приложите к результатам ДЗ все команды по обновлению версии кластера, аналогично как вы делали это для команд установки
* Приложите к результатам ДЗ вывод команды kubectl get nodes -o wide, показывающий статус и версию k8s всех нод кластера после обновления

#### Задание со *

* Создайте минимум 5 нод следующей конфигурации:
  * Для master - 3 узла, 2vCPU, 8GB RAM
  * Для worker – минимум 2 узла, 2vCPU, 8GB RAM
* Разверните отказоустойчивый кластер K8s с помощью kubespray (3 master ноды, минимум 2 worker)
* К результатам ДЗ приложите inventory файл который вы использовали для создания кластера и вывод команды kubectl get nodes –o wide

#### Выполнение задания

Для выполнения задания установить утилиты `yc` и `jq`.

Про создание и удаление витруальных машин с помощью консольной утилиты `yc` можно почитать [здесь](https://teletype.in/@cameda/ntq8QNHIsG1).

Инструкция по установке [containerd.io](https://www.vitaliy.org/post/7242).

Про установку kubelet, kubeadm и kubectl можно почитать [тут](https://www.vitaliy.org/post/6224) и [тут](https://forum.linuxfoundation.org/discussion/864693/the-repository-http-apt-kubernetes-io-kubernetes-xenial-release-does-not-have-a-release-file).

Про обновление кластера можно почитать [тут](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/#upgrading-control-plane-nodes) и [тут](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/).

Чотбы создать виртуальные машины в Яндекс.Облаке, нужно запустить скрипт:
```bash
./create_vm.sh
```

Далее необходимо установить утилиты containerd, kubeadm, kubelet и kubectl. Для этого можно воспользоваться скриптом (прежде нужно дождаться завершения создания виртуальных машин):
```bash
./install_tools.sh
```

Потом создаём кластер:
```bash
./create_cluster.sh
```

Чтобы проверить, что все ноды работают, нужно выполнить команду `kubectl get nodes -o wide` и посмотреть, чтобы в колонке STATUS было значение Ready. Вывод должен быть примерно таким:
```plain
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
master-1   Ready    control-plane   85s   v1.29.7   10.128.0.19   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
worker-1   Ready    <none>          49s   v1.29.7   10.128.0.15   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
worker-2   Ready    <none>          59s   v1.29.7   10.128.0.4    <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
worker-3   Ready    <none>          53s   v1.29.7   10.128.0.26   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
```

Для обновления кластера запускаем скрипт:
```bash
./upgrade_nodes.sh
```

После обновления снова выполним команду `kubectl get nodes -o wide`:
```plain
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
master-1   Ready    control-plane   61m   v1.30.3   10.128.0.19   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
worker-1   Ready    <none>          60m   v1.30.3   10.128.0.15   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
worker-2   Ready    <none>          60m   v1.30.3   10.128.0.4    <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
worker-3   Ready    <none>          60m   v1.30.3   10.128.0.26   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.19
```

Видим, что кластер успешно обновлён.

Для удаления виртуальных машин:
```bash
./remove_vm.sh
```

#### Выполнение задания co *

Для выполнения задания установить утилиты [kubespray](https://github.com/kubernetes-sigs/kubespray), [ansible](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible/ansible.md#installing-ansible), [yc](https://yandex.cloud/en/docs/cli/operations/install-cli) и [jq](https://lindevs.com/install-jq-on-ubuntu).

Чотбы создать виртуальные машины в Яндекс.Облаке, нужно запустить скрипт из папки additional_task:
```bash
./create_vm.sh
```

Для успешного разворачивания кластера, достаточно выполнить шаги из [официальной инструкции](https://github.com/kubernetes-sigs/kubespray?tab=readme-ov-file#usage), отредактировав `inventory/mycluster/hosts.yaml` должным образом.

Troubleshooting:
  * pip install ruamel_yaml
  * удалить access_ip из inventory

Зайдя на мастер ноду и выполнив `kubectl get nodes -o wide`, должны увидеть примерно следующее:
```plain
NAME    STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
node1   Ready    control-plane   9m53s   v1.30.3   10.128.0.10   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.16
node2   Ready    <none>          7m56s   v1.30.3   10.128.0.22   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.16
node3   Ready    <none>          7m56s   v1.30.3   10.128.0.34   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.16
node4   Ready    control-plane   9m14s   v1.30.3   10.128.0.30   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.16
node5   Ready    control-plane   8m55s   v1.30.3   10.128.0.32   <none>        Ubuntu 24.04 LTS   6.8.0-39-generic   containerd://1.7.16
```

Для удаления виртуальных машин:
```bash
./remove_vm.sh
```
