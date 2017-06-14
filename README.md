# Docker massmux/php

  mantainer Massimo S. Musumeci ( massmux (at) denali.uk )

This is a docker image suitable to run any apache-php application in a container. This image is for run any php and apache application. You can run this image and associate with any mysql db. The system also installs letsencrypt and automatically gets certificate for the domain. Set all the vars into the docker-compose file

how to build this image?

```bash
docker build -t massmux/php .
```
then do this to run it (after configuring the docker-compose file):

```bash
docker-compose up -d
```

 The system automatically downloads an app, for example wordpress. Then you simply have to run installer.

 It uses persistent volumes in order to store persistently the database and all the files. Therefore stop and start of the container or all the docker daemon will not affect your data.

 The system uses SSMTP to send emails, therefore be sure to config correctly the vars inside the docker-compose file in order to reflect your external relay host. This will be used to send the emails from your container to outside.

## Contributing

Software developed on Denali group systems. Used Vps in debian OS.

Visit [![Denali](https://www.denali.eu/dena.png)](https://www.denali.eu) for more infos.

