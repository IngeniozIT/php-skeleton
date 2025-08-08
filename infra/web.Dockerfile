# Use PHP 8.4 with Apache base image
FROM php:8.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required for web applications
RUN docker-php-ext-install \
    pcntl \
    pdo_mysql

# Install Xdebug for development/debugging
RUN pecl install xdebug ast \
    && docker-php-ext-enable xdebug ast

# Configure Xdebug for development (disabled by default for performance)
RUN echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Enable Apache mod_rewrite for clean URLs
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory to Apache's document root
WORKDIR /var/www/html

# Copy composer files first for better layer caching
COPY composer.json composer.lock* ./

# Install PHP dependencies (production only for web)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-cache

# Copy the rest of the application
COPY . .

# Set proper permissions for Apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Create a simple index.php if none exists
RUN if [ ! -f index.php ]; then \
        echo '<?php phpinfo(); ?>' > index.php; \
    fi

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
