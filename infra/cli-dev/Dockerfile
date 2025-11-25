ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-cli-alpine

# Install system dependencies and PHP extensions
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        libzip-dev \
        libxml2-dev \
        oniguruma-dev \
        linux-headers \
        git \
    && apk add --no-cache \
        unzip \
        curl \
        bash \
        libzip \
    && docker-php-ext-install -j$(nproc) pcntl zip mbstring xml \
    && pecl install ast \
    && docker-php-ext-enable ast \
    && sh -c 'pecl install xdebug 2>&1 || { \
        git clone --depth 1 --branch master https://github.com/xdebug/xdebug.git /tmp/xdebug && \
        cd /tmp/xdebug && \
        phpize && \
        ./configure && \
        make -j$(nproc) && \
        make install && \
        cd / && \
        rm -rf /tmp/xdebug; \
    }' \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP for development and Xdebug
RUN { \
        echo 'memory_limit=1G'; \
        echo 'max_execution_time=300'; \
        echo 'error_reporting=E_ALL'; \
        echo 'display_errors=On'; \
        echo 'display_startup_errors=On'; \
        echo 'log_errors=On'; \
        echo 'error_log=/tmp/php_errors.log'; \
        echo ''; \
        echo '; Xdebug configuration (disabled by default, enable with XDEBUG_MODE env var)'; \
        echo 'xdebug.start_with_request=trigger'; \
        echo 'xdebug.client_host=host.docker.internal'; \
        echo 'xdebug.client_port=9003'; \
        echo 'xdebug.log=/tmp/xdebug.log'; \
    } > /usr/local/etc/php/conf.d/development.ini

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_CACHE_DIR=/tmp/composer-cache
ENV COMPOSER_MEMORY_LIMIT=-1
ENV XDEBUG_MODE=off

WORKDIR /var/www/html

CMD ["/bin/bash"]
