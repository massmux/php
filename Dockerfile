FROM massmux/debian
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
        php-apc &&\
    rm -rf /var/lib/apt/lists/*


RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini && \
   sed -i "s/upload_max_filesize.*/upload_max_filesize = 64M/g" /etc/php5/apache2/php.ini && \
   sed -i "s/memory_limit.*/memory_limit = 256M/g" /etc/php5/apache2/php.ini && \
   sed -i "s/post_max_size.*/post_max_size = 128M/g" /etc/php5/apache2/php.ini && \
   curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
   echo "<?php phpinfo(); ?>" > /var/www/html/info.php && \
   chown -R www-data:www-data /var/www/html

# install composer
RUN curl -sS https://getcomposer.org/installer | php

## copy files
COPY ./src /src/
RUN  mv /src/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
     mv /src/000-default /etc/apache2/sites-enabled/000-default && \
     mv /src/ssmtp.conf /etc/ssmtp/ssmtp.conf && \
     mv /src/run.sh /run.sh && \
     mv /src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
     chmod +x /run.sh

# Password ssmtp
ENV SSMTP_AUTHUSER test@test.com
ENV SSMTP_AUTHPASS 123456
ENV SSMTP_MAILHUB gw@example.com

# port exposed
EXPOSE 80 22

# running setup commands + supervisord
CMD ["/run.sh"]
