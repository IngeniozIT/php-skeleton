ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-apache

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        zlib1g-dev \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
        linux-headers-amd64 \
        git \
        unzip \
        curl \
        libzip5 \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache VirtualHost
RUN { \
        echo '<VirtualHost *:80>'; \
        echo '    ServerName localhost'; \
        echo '    DocumentRoot /var/www/html/public'; \
        echo '    DirectoryIndex index.php index.html'; \
        echo '    <Directory /var/www/html/public>'; \
        echo '        AllowOverride All'; \
        echo '        Require all granted'; \
        echo '        Options -Indexes +FollowSymLinks'; \
        echo '    </Directory>'; \
        echo '    ErrorLog ${APACHE_LOG_DIR}/error.log'; \
        echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
        echo '</VirtualHost>'; \
    } > /etc/apache2/sites-available/000-default.conf

# Configure PHP for development and Xdebug
RUN { \
        echo 'memory_limit=512M'; \
        echo 'max_execution_time=30'; \
        echo 'max_input_time=60'; \
        echo 'post_max_size=64M'; \
        echo 'upload_max_filesize=64M'; \
        echo 'error_reporting=E_ALL'; \
        echo 'display_errors=On'; \
        echo 'display_startup_errors=On'; \
        echo 'log_errors=On'; \
        echo 'error_log=/var/log/apache2/php_errors.log'; \
        echo 'opcache.enable=1'; \
        echo 'opcache.revalidate_freq=0'; \
        echo 'opcache.validate_timestamps=1'; \
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

# Set Apache ServerName to suppress warnings
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
