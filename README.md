# docker-clav

## Requirements

- docker (https://docs.docker.com/)
- docker-compose (https://docs.docker.com/compose/)

## Build Images

In order to build the images you need to do first:
- Download a GraphDB zip version (http://graphdb.ontotext.com/) and put them in the graphdb folder (ex: graphdb-free-8.11.0-dist.zip)
- Change the GraphDB used version in Dockerfile file inside the graphdb folder (ex: free-8.11.0)
- Clone/download the CLAV2018 rep (https://github.com/jcramalho/CLAV2018) and place it in the same folder as the docker-clav folder.

Then you only need to run `docker-compose -f docker-compose-build.yml up`

## Use already builded docker images

If you want to use the already builded images you only need to download the docker-compose.yml file and run `docker-compose up` in the folder of the file.

## Some notes

If you want to deploy the app in another port/address and you want to have access to swagger docs you should replace the SWAGGER_URL with your URL.

## Backup and Restore scripts

This scripts allow to backup and restore the volumes of the docker containers created with the docker-compose files. The backup script produces two tar files with the volumes data. The restore script use this two tar files to restore.

If you have the containers running and you want to migrate you only need to:
- Run backup script
- Move the backup files to the new location
- Create the containers buiding the images or using the already ones builded in the new location
- Run the restore script in the new location
