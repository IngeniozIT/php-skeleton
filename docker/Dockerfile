# Use the official PHP 8.2 image with Apache
FROM php:8.3-apache

# Install system dependencies and PHP extensions required for most PHP projects
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip

# Install Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install php-ast extension
RUN pecl install ast && docker-php-ext-enable ast

# Configure Xdebug (customize this to your needs)
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the COMPOSER_ALLOW_SUPERUSER environment variable
ENV COMPOSER_ALLOW_SUPERUSER 1

# Set the working directory inside the container
WORKDIR /var/www/html

# Copy the project's composer.json and composer.lock files to the working directory
COPY composer.json ./

# Install project dependencies
RUN composer install --no-scripts --no-autoloader --no-dev

# Copy the rest of the project to the working directory
COPY . .

# Finish composer
RUN composer dump-autoload --optimize

# Apache configuration: Enable mod_rewrite
RUN a2enmod rewrite

# Create a non-root user and switch to it
RUN useradd -m appuser
RUN groupadd appgroup
RUN chown -R appuser:appgroup /var/www/html
USER appuser

# Expose port 80 for Apache
EXPOSE 80

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1