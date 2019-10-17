# docker-clav

## Requirements

- docker (https://docs.docker.com/)
- docker-compose (https://docs.docker.com/compose/)

## Build Images

In order to build the images you need to do first:
- Download a zip of a GraphDB version (http://graphdb.ontotext.com/) and put it in the graphdb folder (ex: graphdb-free-8.11.0-dist.zip)
- Change the GraphDB used version in Dockerfile inside the graphdb folder (ex: free-8.11.0)
- Clone/download the CLAV2018 rep (https://github.com/jcramalho/CLAV2018) and put it in the same folder of the docker-clav folder is

Them you only need to run `docker-compose -f docker-compose-build.yml up`

## Use builded docker images

If you want to use the already builded images you only need to download the docker-compose.yml file and in the folder of the file run `docker-compose up`.

## Some notes

If you want to deploy the app in another port/address and you want to have access to swagger docs you should replace the SWAGGER_URL with your url.

## Backup and Restore scripts

This scripts allow to backup and restore the volumes of the docker containers created with the docker-compose files. The backup produces two tar files with the data. The restore use this two tar files to restore.
