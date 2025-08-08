# Use PHP 8.4 CLI base image
FROM php:8.4-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required for quality tools
RUN docker-php-ext-install \
    pcntl

# Install Xdebug and AST extension for code coverage and static analysis
RUN pecl install xdebug ast \
    && docker-php-ext-enable xdebug ast

# Configure Xdebug for coverage (disabled by default for performance)
RUN echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for better layer caching
COPY composer.json composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy the rest of the application
COPY . .

# Install dev dependencies for quality tools
RUN composer install --optimize-autoloader --no-interaction

# Keep container running for CLI access
CMD ["tail", "-f", "/dev/null"]
