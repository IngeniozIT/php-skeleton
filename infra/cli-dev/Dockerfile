ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-cli

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
        unzip \
        curl \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
        git \
    && docker-php-ext-install -j$(nproc) pcntl zip mbstring xml \
    && pecl install ast \
    && docker-php-ext-enable ast \
    && git clone --depth 1 --branch master https://github.com/xdebug/xdebug.git /tmp/xdebug \
    && cd /tmp/xdebug \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable xdebug \
    && cd / \
    && rm -rf /tmp/xdebug \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP for development
RUN { \
        echo 'memory_limit=1G'; \
        echo 'max_execution_time=300'; \
        echo 'error_reporting=E_ALL'; \
        echo 'display_errors=On'; \
        echo 'display_startup_errors=On'; \
        echo 'log_errors=On'; \
        echo 'error_log=/tmp/php_errors.log'; \
    } > /usr/local/etc/php/conf.d/development.ini

# Configure Xdebug (disabled by default, enable with XDEBUG_MODE env var)
RUN { \
        echo 'xdebug.start_with_request=trigger'; \
        echo 'xdebug.client_host=host.docker.internal'; \
        echo 'xdebug.client_port=9003'; \
        echo 'xdebug.log=/tmp/xdebug.log'; \
    } > /usr/local/etc/php/conf.d/xdebug.ini

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_CACHE_DIR=/tmp/composer-cache
ENV COMPOSER_MEMORY_LIMIT=-1
ENV XDEBUG_MODE=off

WORKDIR /var/www/html

CMD ["/bin/bash"]
