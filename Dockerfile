FROM php:apache
LABEL maintainer="Marc Richter <mail@marc-richter.info>"

ARG MYSQL_DATABASE
ARG MYSQL_ROOT_PASSWORD

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisites from apt
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        git \
        mariadb-client \
        wget \
        unzip \
    && apt-get clean

# Get the latest tagged version of projectsend
RUN git clone https://github.com/projectsend/projectsend.git /var/www/html/ \
    && cd /var/www/html/ \
    && git checkout r$(git tag | sed 's#^r##g' | sort -n | tail -n 1) \
    && rm -rf .git

# Activate required PHP modules
RUN docker-php-source extract \
    && docker-php-ext-configure pdo_mysql && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install gd \
    && docker-php-ext-configure gettext && docker-php-ext-install gettext \
    && docker-php-ext-configure zip && docker-php-ext-install zip \
    && docker-php-source delete

# Install composer
COPY files/get_composer.sh /tmp/get_composer.sh
RUN /bin/sh /tmp/get_composer.sh

RUN cd /var/www/html ; composer install
RUN cp /var/www/html/config/config.sample.php /var/www/html/config/config.php
RUN sed -i'' "s#'DB_NAME', 'database'#'DB_NAME', 'DOCKER_REPLACE_ME'#g" /var/www/html/config/config.php \
    && sed -i'' "s#DOCKER_REPLACE_ME#${MYSQL_DATABASE}#g" /var/www/html/config/config.php \
    && sed -i'' "s#'DB_HOST', 'localhost'#'DB_HOST', 'db'#g" /var/www/html/config/config.php \
    && sed -i'' "s#'DB_USER', 'username'#'DB_USER', 'root'#g" /var/www/html/config/config.php \
    && sed -i'' "s#'DB_PASSWORD', 'password'#'DB_PASSWORD', 'DOCKER_REPLACE_ME'#g" /var/www/html/config/config.php \
    && sed -i'' "s#DOCKER_REPLACE_ME#${MYSQL_ROOT_PASSWORD}#g" /var/www/html/config/config.php

RUN a2enmod rewrite
RUN sed -i'' "s#DocumentRoot.*/var/www/html#DocumentRoot /var/www/html/public#g" /etc/apache2/sites-enabled/000-default.conf

COPY files/wait4db.sh /usr/local/bin/wait4db.sh
RUN chmod +x /usr/local/bin/wait4db.sh
