#!/bin/bash
#file run.sh for php container

## ssmtp configuration
echo "=> Configuring ssmtp"
sed -i "s/AuthUser=.*/AuthUser=$SSMTP_AUTHUSER/g" /etc/ssmtp/ssmtp.conf
sed -i "s/AuthPass=.*/AuthPass=$SSMTP_AUTHPASS/g" /etc/ssmtp/ssmtp.conf
sed -i "s/mailhub=.*/mailhub=$SSMTP_MAILHUB/g" /etc/ssmtp/ssmtp.conf
echo "=> Done!"

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
