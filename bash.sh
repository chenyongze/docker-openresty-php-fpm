#!/bin/bash
docker stop `docker ps -a -q`
docker rm -f `docker ps -a -q`
docker rmi -f `docker images -q`
docker build -t php-openresty ./
# docker run -it -p 80:80 php-openresty bash
docker run -it -d  -p 80:80 -v /opt/docker/php-openresty/src:/usr/local/openresty/nginx/html --name sldc-php-openresty php-openresty
