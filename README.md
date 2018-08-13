# statusxt_microservices
statusxt microservices repository

# Table of content
- [Homework-12 Docker-1](#homework-12-docker-1)

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
