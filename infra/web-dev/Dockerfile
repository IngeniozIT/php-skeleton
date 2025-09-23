ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-apache AS php-base

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
        unzip \
        curl \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
        apache2-utils \
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

FROM composer-base AS web-config

RUN a2enmod rewrite headers ssl deflate expires

RUN { \
        echo '<VirtualHost *:80>'; \
        echo '    ServerName localhost'; \
        echo '    DocumentRoot /var/www/html/public'; \
        echo '    <Directory /var/www/html/public>'; \
        echo '        AllowOverride All'; \
        echo '        Require all granted'; \
        echo '        Options -Indexes +FollowSymLinks'; \
        echo '        # Security headers'; \
        echo '        Header always set X-Content-Type-Options nosniff'; \
        echo '        Header always set X-Frame-Options DENY'; \
        echo '        Header always set X-XSS-Protection "1; mode=block"'; \
        echo '        Header always set Referrer-Policy "strict-origin-when-cross-origin"'; \
        echo '    </Directory>'; \
        echo '    # Logging'; \
        echo '    ErrorLog ${APACHE_LOG_DIR}/error.log'; \
        echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
        echo '    # Compression'; \
        echo '    <Location />'; \
        echo '        SetOutputFilter DEFLATE'; \
        echo '        SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary'; \
        echo '        SetEnvIfNoCase Request_URI \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary'; \
        echo '    </Location>'; \
        echo '</VirtualHost>'; \
    } > /etc/apache2/sites-available/000-default.conf

RUN { \
        echo '; Xdebug configuration for web development'; \
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
        echo 'memory_limit=512M'; \
        echo 'max_execution_time=30'; \
        echo 'max_input_time=60'; \
        echo 'max_input_vars=3000'; \
        echo 'post_max_size=64M'; \
        echo 'upload_max_filesize=64M'; \
        echo 'error_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT'; \
        echo 'display_errors=Off'; \
        echo 'display_startup_errors=Off'; \
        echo 'log_errors=On'; \
        echo 'error_log=/var/log/apache2/php_errors.log'; \
        echo 'default_socket_timeout=60'; \
        echo 'session.cookie_httponly=1'; \
        echo 'session.cookie_secure=0'; \
        echo 'session.use_strict_mode=1'; \
        echo 'expose_php=Off'; \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=256'; \
        echo 'opcache.interned_strings_buffer=16'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.validate_timestamps=1'; \
        echo 'opcache.revalidate_freq=0'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/production.ini

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} appuser && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash appuser

RUN { \
        echo 'alias ll="ls -la"'; \
        echo 'alias la="ls -la"'; \
    } >> /home/appuser/.bashrc

FROM web-config AS final

WORKDIR /var/www/html

COPY composer.json composer.lock* ./

RUN --mount=type=cache,target=/tmp/composer-cache,sharing=locked \
    if [ -f composer.lock ]; then \
        composer install --no-dev --no-scripts --no-autoloader --optimize-autoloader --ansi; \
    else \
        composer update --no-dev --no-scripts --no-autoloader --optimize-autoloader --ansi; \
    fi

RUN composer dump-autoload --optimize --no-dev --ansi

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage 2>/dev/null || true \
    && chmod -R 775 /var/www/html/bootstrap/cache 2>/dev/null || true

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_RUN_DIR=/var/run/apache2
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV XDEBUG_MODE=off

RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

CMD ["apache2-foreground"]
