# docker-clav

## Requirements

- docker (https://docs.docker.com/)
- docker-compose (https://docs.docker.com/compose/)

## Build Images

In order to build the images you need to do first:
- Download a GraphDB zip version (http://graphdb.ontotext.com/) and put them in the graphdb folder (ex: graphdb-free-8.11.0-dist.zip)
- Change the GraphDB used version in Dockerfile file inside the graphdb folder (ex: free-8.11.0)

Then you only need to run `docker-compose -f docker-compose-build.yml up`

## Use already builded docker images

If you want to use the already builded images you only need to download the docker-compose.yml file and run `docker-compose up` in the folder of the file.

## Some notes

You can if you want, change the variables in `.env` file.

## Backup and Restore scripts

This scripts allow to backup and restore the volumes of the docker containers created with the docker-compose files. The backup script produces two tar files with the volumes data. The restore script use this two tar files to restore.

If you have the containers running and you want to migrate you only need to:
- Run backup script
- Move the backup files to the new location
- Create the containers buiding the images or using the already ones builded in the new location
- Run the restore script in the new location
