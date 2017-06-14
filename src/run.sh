#!/bin/bash
#file run.sh for php container

#supervisor
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true

[program:cron]
command=/usr/sbin/cron -f

[program:sshd]
command=/usr/sbin/sshd -D

[program:apache2]
command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"

[program:rsyslog]
command=/usr/sbin/rsyslogd -n
EOF

# SSMTP
cat > /etc/ssmtp/ssmtp.conf <<EOF
# The user that gets all the mails (UID < 1000, usually the admin)
root=postmaster
mailhub=test.com:25
# The address where the mail appears to come from for user authentication.
##rewriteDomain=test.com
##hostname=d56636c16cec
UseTLS=No
UseSTARTTLS=No
# Username/Password
AuthUser=test@test.com
AuthPass=1234567
# Email 'From header's can override the default domain?
FromLineOverride=yes
EOF

## ssmtp configuration
sed -i "s/AuthUser=.*/AuthUser=$SSMTP_AUTHUSER/g" /etc/ssmtp/ssmtp.conf
sed -i "s/AuthPass=.*/AuthPass=$SSMTP_AUTHPASS/g" /etc/ssmtp/ssmtp.conf
sed -i "s/mailhub=.*/mailhub=$SSMTP_MAILHUB/g" /etc/ssmtp/ssmtp.conf


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


#install certbot
cd /etc/letsencrypt
if [ -d "live" ]; then
	echo "cert dir already there"
	#letsencrypt already installed
else
	#installing letsencrypt
	/opt/certbot/certbot-auto --apache --agree-tos  --non-interactive  --text  --rsa-key-size 4096  --email $LETSENC_EMAIL --domains "$LETSENC_DOM"
	echo
fi

#install wp
if [ "${APP}" == "wordpress" ]; then
  cd /var/www/html
  if [ -f wp-login.php ]; then
     echo "File exists."
     #wordpress already installed
  else
     echo "File does not exist."
     #installing wordpress
     wget $DOWNLOAD
     tar xzvf latest.tar.gz
     mv wordpress/* .
     rm index.html
  fi
fi


exec supervisord -n
