# statusxt_microservices
statusxt microservices repository

# Table of content
- [Homework-12 Docker-1](#homework-12-docker-1)
- [Homework-13 Docker-2](#homework-13-docker-2)
- [Homework-14 Docker-3](#homework-14-docker-3)
- [Homework-15 Docker-4](#homework-15-docker-4)
- [Homework-16 Gitlab-CI-1](#homework-16-gitlab-ci-1)

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

# Homework 14 Docker-3
## 14.1 Что было сделано
- скачан архив с микросервисами и распакован в src
- созданы Dockerfile для сборки post-py, comment, ui
```
docker build -t statusxt/post:1.0 ./post-py
docker build -t statusxt/comment:1.0 ./comment
docker build -t statusxt/ui:1.0 ./ui
```
- создана сеть для приложения
```
docker network create reddit
```
- запущены контейнеры:
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:1.0
```
- создан docker volume для mongodb
```
 docker volume create reddit_db 
```
- контейнеры перезапущены с новыми парметрами, теперь данные в базе не зависят о перезапуска контейнеров
```
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
```

В рамках задания со *:
- запущены контейнеры с другими сетевыми алиасами, при запуске контейнеров (docker run) заданы переменные окружения соответствующие новым сетевым алиасам:
```
docker run -d --network=reddit --network-alias=post_db_1 \
              --network-alias=comment_db_1 mongo:latest
docker run -d --network=reddit --network-alias=post_1 \
              -e POST_DATABASE_HOST=post_db_1 andywow/post:1.0
docker run -d --network=reddit --network-alias=comment_1 \
              -e COMMENT_DATABASE_HOST=comment_db_1 andywow/comment:1.0
docker run -d --network=reddit -p 9292:9292 --network-alias=ui \
              -e COMMENT_SERVICE_HOST=comment_1 \
              -e POST_SERVICE_HOST=post_1 andywow/ui:1.0
```
- собран образ на основе alpine linux
- произведены оптимизации ui образа - удаление кэша, приложений для сборки
```
statusxt/ui    5.0    521a666364d1    23 hours ago    58.5MB
statusxt/ui    4.0    223d64bf1a3a    23 hours ago    209MB
statusxt/ui    3.0    c4c2f1396a5b    24 hours ago    58.4MB
statusxt/ui    2.0    8e8787069c58    25 hours ago    460MB
statusxt/ui    1.0    8c6d705411e2    25 hours ago    778MB
```

## 14.2 Как запустить проект
### 14.2.1 Base
в каталоге src:
```
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
```
### 14.2.2 *
в каталоге src:
```
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:5.0
```

## 14.3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9292

# Homework 15 Docker-4
## 15.1 Что было сделано
- протестирована работа контейнера с использованием none и host драйвера
```
docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker ps
docker run --network host --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker-machine ssh docker-host ifconfig
docker run --network host -d nginx
docker run --network host -d nginx
```
- nginx запустить несколько раз не получится, потому что порт будет занят первым запущенным экземпляром
- при запуске контейнера с none драйвером создается новый namespace, при запуске с host драйвером используется namespace хоста
- создана bridge-сеть в docker, запущен проект с использоваением этой сети:
```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment  statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
```
- созданы 2 bridge-сети в docker, запущен проект с использоваением этих сетей:
```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker run -d --network=front_net -p 9292:9292 --name ui  statusxt/ui:1.0
docker run -d --network=back_net --name comment  statusxt/comment:1.0
docker run -d --network=back_net --name post  statusxt/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
docker network connect front_net post
docker network connect front_net comment
```
- установлен docker-compose
```
pip install docker-compose 
```
- создан файл dockercompose.yml с описанием проекта
- в dockercompose.yml добавлены 2 сети, сетевые алиасы, параметризованы порт публикации, версии сервисов
- переменные задаются в файле .env
- базовое имя проекта задется переменной COMPOSE_PROJECT_NAME
- работа docker-compose проверена:
```
docker-compose up -d
docker ps
```

## 15.2 Как запустить проект

в каталоге src:
```
docker kill $(docker ps -q)
docker-compose up -d
```

## 15.3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9292

# Homework 16 Gitlab-CI-1
## 16.1 Что было сделано
- создана ВМ в GCP, установлен docker-ce, docker-compose
- в каталоге /srv/gitlab/ создан docker-compose.yml с описанием gitlab-ci:
```
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://35.187.88.136'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```
- запущен gitlab-ci:
```
docker-compose up -d 
```
- созданы группа и проект в gitlab-ci
- добавлен remote в <username>_microservices:
```
git checkout -b gitlab-ci-1
git remote add gitlab http://<your-vm-ip>/homework/example.git
git push gitlab gitlab-ci-1
```
- создан файл .gitlab-ci.yml с описанием пайплайна
- создан и зарегистрирован runner:
```
docker run -d --name gitlab-runner --restart always \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest 
docker exec -it gitlab-runner gitlab-runner register
```
- добавлен исходный код reddit в репозиторий:
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab gitlab-ci-1
```
- в описание pipeline добавлен вызов теста в файле simpletest.rb
- добавлена библиотека для тестирования в reddit/Gemfile приложения
- теперь на каждое изменение в коде приложения будет запущен тест

Интеграция со slack чатом:
- Project Settings > Integrations > Slack notifications. Нужно установить active, выбрать события и заполнить поля с URL Slack webhook
- ссылка на тестовый канал https://devops-team-otus.slack.com/messages/CB5SJCHCY/

## 16.2 Как запустить проект

на машине с gitlab-ci в каталоге /srv/gitlab/:
```
docker-compose up -d
```

## 16.3 Как проверить
перейти в браузере по ссылке http://docker-host_ip
