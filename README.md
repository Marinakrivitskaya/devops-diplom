# Дипломный практикум в Cloud: Amazon Web Services"

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера AWS.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

## Этапы выполнения:

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в облаке AWS при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:
- Для выполнения задания следует активировать купон AWS, полученный от координатора курса;
- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.
1. При помощи IAM создайте service account, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой.
1. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
   1. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)
   1. Альтернативный вариант: S3 bucket в созданном AWS аккаунте
1. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
   1. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.
   1. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создавайемый Terraform-ом по-умолчанию (*default*).
1. Создайте VPC при помощи готового [модуля](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) от AWS.
1. При помощи Terraform подготовьте как минимум 3 виртуальных машины EC2 для создания Kubernetes-кластера. Выберите тип виртуальной машины самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.
1. Во время выполнения также понадобится создать [security groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) и некоторые другие ресурсы.
1. Следует учитывать, что доступ к EC2 должен быть возможен через Интернет, а не только по локальной сети.
1. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
1. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.


Ожидаемые результаты:
1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
1. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфрастуктуры.

Это можно сделать двумя способами:
1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.
   1. подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)
   1. задеплоить Kubernetes на подготовленные ранее ec2 инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
1. Альтернативый вариант: воспользуйтесь сервисом [EKS](https://aws.amazon.com/eks/) (Amazon Elastic Kubernetes Service)
   1. воспользуйте модулем [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
   1. дополните уже существующую Terraform конфигурацию, новый проект создавать не нужно.

Ожидаемый результат:
1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:
1. Рекомендуемый вариант:
   1. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.
   2. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:
   1. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:
1. Git репозиторий с тестовым приложением и Dockerfile.
2. Dockerhub регистр с собранным docker image.

### Подготовка Kubernetes конфигурации

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортет](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
1. Задеплоить тестовое приложение, например [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемые способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
1. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

###  Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:
1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:
1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторий с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега в репозитории происходит деплой соответсвующего Docker образа.


###  Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстировать создание всех рессурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.


Выполнение работы.
===========
## Создание облачной инфраструктуры
1. Создала репозиторий с конфигурационными файлами Terraform: [https://github.com/Marinakrivitskaya/devops-diplom/tree/main/terraform](https://github.com/Marinakrivitskaya/devops-diplom/tree/main/terraform)

2. Убедилась, что команды `terraform destroy` и `terraform apply` работают:
<img width="949" alt="terraform destroy" src="https://user-images.githubusercontent.com/67638098/140987659-1f58e350-23ad-43a1-a79f-2c8f5763ceb6.png">

<img width="956" alt="terraform apply" src="https://user-images.githubusercontent.com/67638098/140987687-e146980b-4b5d-4171-86fa-b7c1bc22674a.png">

3. Изменения проходят успешно , используя web-интерфейс Terraform cloud:
<img width="1280" alt="Screenshot 2021-11-09 at 19 53 54" src="https://user-images.githubusercontent.com/67638098/140987926-ed84fb5d-3af8-47ff-be68-c875bdf73926.png">
<img width="1257" alt="Screenshot 2021-11-09 at 20 06 20" src="https://user-images.githubusercontent.com/67638098/140988403-287ce38c-ea88-4701-8de7-c15830305767.png">

### Создание Kubernetes кластера

4. Создала кластер Kubernetes, при помощи Ansible. Inventory файл: [https://github.com/Marinakrivitskaya/devops-diplom/blob/main/ansible/inventory.ini](https://github.com/Marinakrivitskaya/devops-diplom/blob/main/ansible/inventory.ini)

``` 
pip3 install -r requirements.txt
ansible-playbook -i kubespray/inventory/mycluster/inventory.ini  kubespray/cluster.yml -u ubuntu --ask-pass -b --ask-become-pass 
```
<img width="1280" alt="Screenshot 2021-11-10 at 22 14 20" src="https://user-images.githubusercontent.com/67638098/141194556-8a20f4a1-5386-4de3-85ac-0eadc3b4a9fd.png">

### Создание тестового приложения

5. Подготовила тестовое приложение, на [Gitlab](https://gitlab.com/Marinakrivitskaya/diplom_project.git) 
6. Dockerfile для создания образа приложения:

```
FROM nginx:latest
COPY html /var/www/html
COPY nginx.conf /etc/nginx/nginx.conf
```
<img width="1279" alt="gitlab" src="https://user-images.githubusercontent.com/67638098/143019856-b50fb8ec-08cb-4b8c-9e45-048a52ace356.png">

<img width="1255" alt="Screenshot 2021-11-29 at 13 22 53" src="https://user-images.githubusercontent.com/67638098/143869668-3fa16e56-e6c7-4400-81a2-28ea5039bfb1.png">


Ссылка на тестовое приложение
```
http://3.144.88.123:8090/
```

### Создание Kubernetes кластера

7.  Репозиторий с конфигурацией [Kubernetes](https://github.com/Marinakrivitskaya/kube-prometheus.git) кластера

```
git clone https://github.com/Marinakrivitskaya/kube-prometheus.git
cd kube-prometheus
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/
```
<img width="887" alt="prometheus" src="https://user-images.githubusercontent.com/67638098/143025176-67baaefe-6be5-410d-9a1b-b9620fd4d5a9.png">

Ссылка на веб интерфейс Grafana:

```
URL: http://3.144.88.123:30000
user: admin
password: admin
```
<img width="1280" alt="Screenshot 2021-11-29 at 13 36 28" src="https://user-images.githubusercontent.com/67638098/143869430-24748b87-e5b2-44cb-884e-ba7577934c38.png">

###  Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами [Terraform](https://github.com/Marinakrivitskaya/devops-diplom/tree/main/terraform)

2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.

<img width="1280" alt="Screenshot 2021-11-09 at 19 53 54" src="https://user-images.githubusercontent.com/67638098/140987926-ed84fb5d-3af8-47ff-be68-c875bdf73926.png">
<img width="1257" alt="Screenshot 2021-11-09 at 20 06 20" src="https://user-images.githubusercontent.com/67638098/140988403-287ce38c-ea88-4701-8de7-c15830305767.png">

3. Репозиторий с конфигурацией [ansible](https://github.com/Marinakrivitskaya/devops-diplom/blob/main/ansible/inventory.ini), если был выбран способ создания Kubernetes кластера при помощи ansible.

4. Ссылка на [тестовое приложение](https://gitlab.com/Marinakrivitskaya/diplom_project.git).

5. Репозиторий с конфигурацией [Kubernetes](https://github.com/Marinakrivitskaya/kube-prometheus.git) кластера.

6. Ссылка на веб интерфейс [Grafana](http://3.144.88.123:30000) с данными доступа.

