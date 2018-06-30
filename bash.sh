#!/bin/bash
docker stop `docker ps -a -q`
docker rm -f `docker ps -a -q`
docker rmi -f `docker images -q`
docker build -t openresty-php7 ./
docker run -it -d  -p 87:80 -p 1443:443 -v /opt/docker/php-openresty/src:/usr/local/openresty/nginx/html --name sldc-php-openresty openresty-php7
