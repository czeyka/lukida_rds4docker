FROM php:8.4-apache-alpine

# Install required PHP extensions and system dependencies
RUN apk add --no-cache \
    mariadb-client \
    git \
    curl \
    libxml2-dev \
    netcat-openbsd \
    && docker-php-ext-install \
    mysqli \
    pdo \
    pdo_mysql \
    xml \
    simplexml \
    && docker-php-ext-enable \
    mysqli \
    pdo \
    pdo_mysql

# Install PECL Solr module
RUN apk add --no-cache \
    autoconf \
    g++ \
    make \
    curl-dev \
    && pecl install solr \
    && docker-php-ext-enable solr \
    && apk del autoconf g++ make

# Install pear and File_MARC
RUN apk add --no-cache \
    php-pear \
    && pear install File_MARC

# Enable Apache modules required for URL rewriting
RUN a2enmod rewrite headers

# Set PHP error logging
RUN echo "error_log = /var/log/php/error.log" >> /usr/local/etc/php/conf.d/docker-php.ini

# Create log directories
RUN mkdir -p /var/log/php && chmod 755 /var/log/php

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]