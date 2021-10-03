#!/bin/bash
docker stop `docker ps -a -q`
docker rm -f `docker ps -a -q`
docker rmi -f `docker images -q`
docker build -t openresty-php7 ./
docker run -it -d  -p 87:80 -p 1443:443 -v /opt/docker/php-openresty/src:/usr/local/openresty/nginx/html --name sldc-php-openresty openresty-php7


docker run -it -d  -p 80:80 -p 443:443  -v /data/shengle-conf/nginx/conf.d:/etc/nginx/conf.d -v /home/wwwlogs:/home/www-data/wwwlogs -v /data/wwwroot:/var/www/html --name shengle-o-p s-o-p /usr/bin/supervisord -n -c /etc/supervisord.conf
