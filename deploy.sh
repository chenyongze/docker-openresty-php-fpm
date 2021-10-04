#!/bin/bash
# 部署项目
# 重新构建

set -e
CURL_PATH=/app/docker-openresty-php-fpm
cd /app/docker-openresty-php-fpm

export_image() {
    echo "[export] 开始 启动 "
    docker export shengle-o-p >shengle-o-p.tar
    echo "[export] 启动 完成"
}

import_image() {
    echo "[import] 开始 启动 "
    docker import ./shengle-o-p.tar s-o-p
    echo "[import] 启动 完成"
}

stop() {
    echo "[stop] 开始 启动 "
    docker stop shengle-o-p
    docker rm shengle-o-p
    echo "[stop] 启动 完成"
}

start() {
    echo "[start] 开始 启动 "
    docker run -it -d -p 9080:80 -p 9443:443 \
        -v $CURL_PATH/php/php.ini:/usr/local/etc/php/php.ini \
        -v $CURL_PATH/php/php-fpm.d:/usr/local/etc/php-fpm.d \
        -v $CURL_PATH/nginx/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
        -v $CURL_PATH/nginx/conf.d:/etc/nginx/conf.d \
        -v $CURL_PATH/supervisor/supervisord.conf:/etc/supervisord.conf \
        -v $CURL_PATH/supervisor/conf.d:/etc/supervisor/conf.d \
        -v /app:/app \
        -v /app/wwwlogs:/home/www-data/wwwlogs \
        --name shengle-o-p \
        s-o-p \
        /usr/bin/supervisord -n -c /etc/supervisord.conf
    echo "[start] 启动 完成"
}

# 部署
deploy() {
    # 导出镜像
    # export_image
    # 导入镜像
    import_image
    # 停止镜像
    stop
    # 启动
    start
}

deploy
