# statusxt_microservices
statusxt microservices repository

# Table of content
- [Homework-12 Docker-1](#homework-12-docker-1)
- [Homework-13 Docker-2](#homework-13-docker-2)

# Homework 12 Docker-1
## 12.1 Что было сделано
Текущее окружение - WSL
- установлен Docker (windows)
- установлен docker-ce в WSL, добавлены переменные среды:
```
export DOCKER_HOST=localhost:2375
```
- протестированы основные функции docker:
```
docker images
docker version
docker run hello-world
docker ps
docker ps -a
docker images
docker run -it ubuntu:16.04 /bin/bash
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
docker start 999116cae390
docker attach 999116cae390
docker ps
docker exec -it 999116cae390 bash
docker commit 999116cae390 yourname/ubuntu-tmp-file
docker images >docker-1.log
docker inspect 7aa3602ab41e
docker inspect 999116cae390
docker kill $(docker ps -q)
docker system df
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
```
В рамках задания со *:
- docker inspect <u_container_id> выводит информацию о контейнере - сущности, созданной на основе образа, с определенной конфигурацией (cpu, memory, network)
- docker inspect <u_image_id> выводит информацию об образе - по сути снэпшоту диска контейнера

## 12.2 Как запустить проект
в корне репозитория:
```
docker run hello-world
```

## 12.3 Как проверить
в корне репозитория:
```
docker images
docker ps -a
```

# Homework 13 Docker-2
## 13.1 Что было сделано
- создан новый проект docker в GCE
- gcloud настроен на новый проект:
```
gcloud config set project docker-213305
```
- установлен docker-machine в WSL
- с помощью docker-machine создан docker-host в GCP
- назначен удаленный докер-демон для докер-клиента:
```
eval $(docker-machine env docker-host)
```
- проверена работа контейнера в неймспейса хоста (--pid host), в этом случае htop видит все процессы, а без ключ - запущенные в контейнере
- созданы Dockerfile, mongod.conf, db_config, start.sh
- собран и проверен образ:
```
docker build -t reddit:latest .
docker images -a
docker run --name reddit -d --network=host reddit:latest
docker-machine ls
```
- образ загружен в docker hub, и запущен локально из другой консоли:
```
docker login
docker tag reddit:latest statusxt/otus-reddit:1.0
docker push statusxt/otus-reddit:1.0
# другая консоль
docker run --name reddit -d -p 9292:9292 statusxt/otus-reddit:1.0
```
- проведены различные проверки:
```
docker logs reddit -f
docker exec -it reddit bash
docker ps
docker ps -a
docker start reddit
docker stop reddit
docker ps -a
docker rm reddit
docker ps -a
docker run --name reddit --rm -it statusxt/otus-reddit:1.0 bash
docker ps -a
docker inspect statusxt/otus-reddit:1.0
docker inspect statusxt/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
docker run --name reddit -d -p 9292:9292 statusxt/otus-reddit:1.0
docker exec -it reddit bash
docker diff reddit
docker stop reddit && docker rm reddit
docker run --name reddit --rm -it statusxt/otus-reddit:1.0 bash
```

В рамках задания со *:
- реализовано создание инстансов с помощью Terraform, их количество задается переменной count_vm
- созданы плейбуки Ansible base.yml, deploy.yml, docker.yml, site.yml для установки докера и запуска там образа приложения с использованием динамического инвентори
- создан шаблон пакера app.json, который делает образ с уже установленным Docker при помощи ansible плейбука packer_docker.yml

## 13.2 Как запустить проект
### 13.2.1 Base
в каталоге docker-monolith:
```
docker build -t reddit:latest .
docker images -a
docker run --name reddit -d --network=host reddit:latest
```
### 13.2.2 *
в каталоге docker-monolith/infra:
```
cd terraform/stage && terraform apply
cd ../../ansible && ansible-playbook playbooks/site.yml
cd ../ && packer build -var-file=packer/variables.json packer/app.json
cd terraform/stage && terraform destroy
```

## 13.3 Как проверить
перейти в браузере по ссылке http://app_external_ip:9292
