#!/bin/bash
#file run.sh for php container

## ssmtp configuration
echo "=> Configuring ssmtp"
sed -i "s/AuthUser=.*/AuthUser=$SSMTP_AUTHUSER/g" /etc/ssmtp/ssmtp.conf
sed -i "s/AuthPass=.*/AuthPass=$SSMTP_AUTHPASS/g" /etc/ssmtp/ssmtp.conf
sed -i "s/mailhub=.*/mailhub=$SSMTP_MAILHUB/g" /etc/ssmtp/ssmtp.conf
echo "=> Done!"

## configure php
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini && \
sed -i "s/memory_limit.*/memory_limit = ${PHP_MEMORY_LIMIT}/g" /etc/php5/apache2/php.ini && \
echo "<?php phpinfo(); ?>" > /var/www/html/info.php && \
chown -R www-data:www-data /var/www/html

if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi


if [ "${CONTAINER_ROOT_PASS}" != "**None**" ]; then
        echo "root:$CONTAINER_ROOT_PASS" | chpasswd
fi



exec supervisord -n
