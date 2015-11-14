# Docker massmux/php

  mantainer Massimo S. Musumeci ( massmux (at) denali.uk )

This is a docker image suitable to run any apache-php application in a container. This image is for run any php and apache application. You can run this image and associate with any mysql db or mariadb.

how to build this image?

```bash
docker build -t massmux/php .
```
then do this to run it:

```bash
docker-compose up -d
```

then call with browser to port 8000, you will see basic apache webpage. The webserver is ready to serve php code and static pages. You can now associate to this image a php web app to run. There are several ready to run images build by denali, please read below.

A set of prebuild images for wordpress, joomla, prestashop is ready on the denali/ docker hub account and you can simply use them. 

In order to run an application like wordpress, create a new dir with empty content and put inside it a docker-compose.yml file with the following content. Then run the compose as already seen

```bash
web:
  image: massmux/php
  ports:
    - "9000:80"
    - "2222:22"
  volumes:
    - /<yourlocalpath>/html:/var/www/html
  environment:
    APP: wordpress
    CONTAINER_ROOT_PASS: <yourrootpass>
    AUTHORIZED_KEYS: <yourkeyhere>
    SSMTP_AUTHUSER: test@test.com
    SSMTP_AUTHPASS: 123456
    SSMTP_MAILHUB: gw@example.com
  mem_limit: 1000m
```

The configured system will listen to port 8000. It uses persistent volumes in order to store persistently the database and all the files. Therefore stop and start of the container or all the docker daemon will not affect your data.

The system uses SSMTP to send emails, therefore be sure to config correctly the vars inside the docker-compose file in order to reflect your external relay host. This will be used to send the emails from your container to outside.

## Contributing

Software developed on Denali group systems. Used Vps in debian OS.

Visit [![Denali](https://www.denali.eu/dena.png)](https://www.denali.eu) for more infos.

