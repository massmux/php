FROM massmux/debian:latest
MAINTAINER Massimo Musumeci <massmux@denali.uk>
LABEL php.version="1.0"
LABEL vendor="TRITEMA SA"

# Install base php,apache,letsencrypt
ENV DEBIAN_FRONTEND noninteractive

# install apache & php
RUN 	apt-get update &&\
	apt-get -yq install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 php5 php5-common php5-gd php5-mysql php5-imap phpmyadmin php5-cli php5-cgi libapache2-mod-fcgid apache2-suexec php-pear php-auth php5-mcrypt mcrypt php5-imagick imagemagick libruby libapache2-mod-python php5-curl php5-intl php5-memcache php5-memcached php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached libapache2-mod-passenger ssmtp pwgen wget rsyslog cron

# --- Synchronize the System Clock
RUN apt-get -y install ntp ntpdate

# install hhvm
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN echo deb http://dl.hhvm.com/debian jessie main | tee /etc/apt/sources.list.d/hhvm.list
RUN apt-get update && apt-get -yq install hhvm

# config apache
ADD ./src/apache_default /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# enable modules
RUN a2enmod suexec rewrite ssl actions include dav_fs dav auth_digest cgi headers

# install composer
RUN curl -sS https://getcomposer.org/installer | php

# install letsencrypt
RUN mkdir /opt/certbot &&\
        cd /opt/certbot &&\
        wget https://dl.eff.org/certbot-auto &&\
	chmod +x /opt/certbot/certbot-auto


## copy files
COPY ./src /src/
RUN  mv /src/run.sh /run.sh && \
     chmod +x /run.sh

# ssmtp
ENV SSMTP_AUTHUSER test@test.com
ENV SSMTP_AUTHPASS 123456
ENV SSMTP_MAILHUB gw@example.com

# php variables
ENV PHP_UPLOAD_MAX_FILESIZE 50M
ENV PHP_POST_MAX_SIZE 50M
ENV PHP_MEMORY_LIMIT 256M

# port exposed
EXPOSE 80 22 443

# volumes
VOLUME ["/etc/apache2", "/var/www/html", "/etc/letsencrypt"]

# entrypoint
CMD ["/run.sh"]
