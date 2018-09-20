# Use Alpine Linux
FROM php:7.2.10-fpm-alpine

# Maintainer
LABEL maintainer="yongze.chen <sapphire.php@gmail.com>"

# Set Timezone Environments
ENV TIMEZONE  Asia/Shanghai

RUN apk add --update tzdata  \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime  \
    && echo "${TIMEZONE}" > /etc/timezone  \
    && apk del tzdata  \
    && apk add --no-cache --virtual .build-deps \
                 curl \
                 g++ \
                 make \
                 autoconf \
                 openssl-dev  \
                 libaio  \
                 libaio-dev \
                 linux-headers \
                 zlib-dev \
    && apk add --no-cache \
                 bash \
                 openssh \
                 libssl1.0 \
                 libxslt-dev \
                 libjpeg-turbo-dev \
                 libwebp-dev \
                 libpng-dev \
                 libxml2-dev \
                 freetype-dev \
                 libmcrypt \
                 freetds-dev  \
                 libmemcached-dev  \
                 cyrus-sasl-dev  \
    && docker-php-source extract  \
    && docker-php-ext-configure pdo  \
    && docker-php-ext-configure pdo_mysql  \
    && docker-php-ext-configure mysqli  \
    && docker-php-ext-configure opcache  \
    && docker-php-ext-configure exif  \
    && docker-php-ext-configure sockets  \
    && docker-php-ext-configure soap  \
    && docker-php-ext-configure bcmath  \
    && docker-php-ext-configure pcntl  \
    && docker-php-ext-configure sysvsem  \
    && docker-php-ext-configure tokenizer  \
    && docker-php-ext-configure zip  \
    && docker-php-ext-configure xsl  \
    && docker-php-ext-configure shmop  \
    && docker-php-ext-configure gd \
                                --with-jpeg-dir=/usr/include \
                                --with-png-dir=/usr/include \
                                --with-webp-dir=/usr/include \
                                --with-freetype-dir=/usr/include  \
    && pecl install swoole redis xdebug mongodb memcached  \
    && pecl clear-cache  \
    && docker-php-ext-enable swoole redis xdebug mongodb memcached \
    && docker-php-ext-install pdo \
                           pdo_mysql \
                           mysqli \
                           opcache \
                           exif \
                           sockets \
                           soap \
                           bcmath \
                           pcntl \
                           sysvsem \
                           tokenizer \
                           zip \
                           xsl \
                           shmop \
                           gd  \
    && docker-php-source delete  \
    && apk del .build-deps  \
    && ln -sf /dev/stdout /usr/local/var/log/php-fpm.access.log  \
    && ln -sf /dev/stderr /usr/local/var/log/php-fpm.error.log  \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer  \
    && curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar  \
    && chmod +x /usr/local/bin/phpunit


# Docker Build Arguments
ARG RESTY_VERSION="1.13.6.2"
ARG RESTY_OPENSSL_VERSION="1.0.2k"
ARG RESTY_PCRE_VERSION="8.42"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    "
ARG RESTY_CONFIG_OPTIONS_MORE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"

# 1) Install apk dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
    && apk add --no-cache \
        gd \
        geoip \
        libgcc \
        libxslt \
        zlib \
        supervisor \
        bash \
    && cd /tmp \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION} \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
    && apk del .build-deps \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log \
    && rm -rf /usr/local/openresty/nginx/html/*


# Add runtime 
RUN mkdir -p /opt/Runtime
RUN chmod -R 777 /opt/Runtime

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

# Copy nginx configuration files
COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY conf/nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# Copy php configuration files
COPY conf/php/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy supervisord configuration file
COPY conf/supervisord.conf /etc/supervisord.conf

# copy in code
COPY src/ /usr/local/openresty/nginx/html/

WORKDIR /usr/local/openresty/nginx/html/

EXPOSE 443 80 9000

CMD ["/usr/bin/supervisord", "-n","-c", "/etc/supervisord.conf"]
