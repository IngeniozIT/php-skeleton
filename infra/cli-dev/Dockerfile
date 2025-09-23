ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli AS php-base

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
        unzip \
        curl \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
        bash-completion \
        && rm -rf /var/lib/apt/lists/*

FROM php-base AS php-extensions

RUN docker-php-ext-install -j$(nproc) \
        pcntl \
        zip \
        mbstring \
        xml \
        dom

RUN --mount=type=cache,target=/tmp/pear,sharing=locked \
    pecl install -o -f \
        xdebug \
        ast \
    && docker-php-ext-enable \
        xdebug \
        ast \
    && php -m | grep -i xdebug

FROM php-extensions AS composer-base

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_CACHE_DIR=/tmp/composer-cache
ENV COMPOSER_MEMORY_LIMIT=-1

RUN mkdir -p /tmp/composer-cache && chmod 777 /tmp/composer-cache

FROM composer-base AS development

RUN { \
        echo '; Xdebug configuration for development'; \
        echo '; Extension is already enabled by docker-php-ext-enable'; \
        echo '; Mode controlled by XDEBUG_MODE environment variable (default: off)'; \
        echo 'xdebug.start_with_request=trigger'; \
        echo 'xdebug.client_host=host.docker.internal'; \
        echo 'xdebug.client_port=9003'; \
        echo 'xdebug.log=/tmp/xdebug.log'; \
        echo 'xdebug.discover_client_host=1'; \
        echo 'xdebug.idekey=VSCODE'; \
        echo 'xdebug.output_dir=/tmp'; \
        echo 'xdebug.profiler_output_name=cachegrind.out.%t'; \
        echo 'xdebug.max_nesting_level=512'; \
    } > /usr/local/etc/php/conf.d/99-xdebug-custom.ini

RUN { \
        echo 'memory_limit=1G'; \
        echo 'max_execution_time=300'; \
        echo 'error_reporting=E_ALL'; \
        echo 'display_errors=On'; \
        echo 'display_startup_errors=On'; \
        echo 'log_errors=On'; \
        echo 'error_log=/tmp/php_errors.log'; \
        echo 'default_socket_timeout=300'; \
        echo 'auto_prepend_file='; \
        echo 'auto_append_file='; \
    } > /usr/local/etc/php/conf.d/development.ini

WORKDIR /var/www/html

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} appuser && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash appuser

RUN { \
        echo 'alias ll="ls -la"'; \
        echo 'alias la="ls -la"'; \
    } >> /home/appuser/.bashrc

FROM development AS final

COPY composer.json composer.lock* ./

RUN --mount=type=cache,target=/tmp/composer-cache,sharing=locked \
    if [ -f composer.lock ]; then \
        composer install --no-scripts --no-autoloader --ansi; \
    else \
        composer update --no-scripts --no-autoloader --ansi; \
    fi

RUN composer dump-autoload --optimize --ansi

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php -v > /dev/null || exit 1

ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV XDEBUG_MODE=off

CMD ["/bin/bash"]
