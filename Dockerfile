FROM denali/debian
MAINTAINER Massimo Musumeci <massmux@denali.uk>

# Install base packages apache php ssmtp
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -yq install \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-gd \
        php5-curl \
        php-pear \
	php5-mcrypt \
	php5-imagick \
	php5-fpm \
	apache2-prefork-dev \
	apache2-suexec \
	libapache2-mod-dnssd \
	libapache2-mod-fcgid \
	libapache2-mod-python \
        ssmtp \
        php-apc \
	pwgen \
	php-apc &&\
	echo "ServerName localhost" >> /etc/apache2/apache2.conf


# config to enable .htaccess
ADD ./src/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# install composer
RUN curl -sS https://getcomposer.org/installer | php

## copy files
COPY ./src /src/
RUN  mv /src/ssmtp.conf /etc/ssmtp/ssmtp.conf && \
     mv /src/run.sh /run.sh && \
     mv /src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
     chmod +x /run.sh


# Password ssmtp
ENV SSMTP_AUTHUSER test@test.com
ENV SSMTP_AUTHPASS 123456
ENV SSMTP_MAILHUB gw@example.com

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 50M
ENV PHP_POST_MAX_SIZE 50M
ENV PHP_MEMORY_LIMIT 256M

# port exposed
EXPOSE 80 22

# running setup commands + supervisord
CMD ["/run.sh"]
