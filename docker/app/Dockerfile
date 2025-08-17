# Multi-stage build for Laravel application
FROM php:8.3-fpm as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libgd-dev \
    libicu-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache

# Install Redis extension
RUN pecl install redis-6.0.2 && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files
COPY src/composer.json src/composer.lock* ./

# Create laravel user
RUN groupadd -g 1000 www \
    && useradd -u 1000 -ms /bin/bash -g www www

# Development stage
FROM base as development

# Install Xdebug for development
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Copy Xdebug configuration
COPY docker/app/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install dependencies
RUN composer install --no-scripts --no-autoloader

# Copy application code
COPY src/ .

# Create necessary Laravel directories if they don't exist
RUN mkdir -p /var/www/html/storage \
    && mkdir -p /var/www/html/storage/app \
    && mkdir -p /var/www/html/storage/app/public \
    && mkdir -p /var/www/html/storage/framework \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/bootstrap/cache \
    && chown -R www:www /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Generate autoloader
RUN composer dump-autoload --optimize

USER www

EXPOSE 9000

# Production stage
FROM base as production

# Set production PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install dependencies without dev packages
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application code
COPY src/ .

# Create necessary Laravel directories if they don't exist
RUN mkdir -p /var/www/html/storage \
    && mkdir -p /var/www/html/storage/app \
    && mkdir -p /var/www/html/storage/app/public \
    && mkdir -p /var/www/html/storage/framework \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/bootstrap/cache \
    && chown -R www:www /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Generate autoloader
RUN composer dump-autoload --optimize

# Clear caches
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

USER www

EXPOSE 9000
