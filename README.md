# docker-clav

## Requirements

- `git`
- `docker` >= 17.06.0 (https://docs.docker.com/)
- `docker-compose` >= 1.18.0 (https://docs.docker.com/compose/)

## Build Images

In order to build the images you need to do first:
- Download a GraphDB zip version (http://graphdb.ontotext.com/) and put them in the graphdb folder (ex: `graphdb-free-8.11.0-dist.zip`)
- Change the GraphDB used version in Dockerfile file inside the graphdb folder (ex: `free-8.11.0`)

Then you only need to run `docker-compose -f docker-compose-build.yml up`

## Use already builded docker images

If you want to use the already builded images you only need to run `docker-compose up`.

## Some notes

You can if you want, change the variables in `.env` file.

## Backup and Restore scripts

This scripts allow to backup and restore the volumes of the docker containers created with the docker-compose files. The backup script produces two tar files with the volumes data. The restore script use this two tar files to restore.

If you have the containers running and you want to migrate you only need to:
- Run backup script
- Move the backup files to the new location
- Create the containers buiding the images or using the already ones builded in the new location
- Run the restore script in the new location

## Development guide

### Preparation

First you shoud install the requirements.

Then you clone the git rep, change to `kong` branch and obtain the submodules content:

```bash
git clone https://github.com/jcm300/docker-clav.git
cd docker-clav
git checkout kong
git submodule update --init
```

After that you need to get an GraphDB distribution, the standalone server version, (http://graphdb.ontotext.com/) and put them in the `graphdb` folder.

Change the GraphDB version in the env variable `GRAPHDB_VERSION` in `.env` file. This version should be the same as that comes with the name file (ex: `graphdb-free-8.11.0-dist.zip` as `free-8.11.0` as version)

If you have an new ontology version, put it in the `graphdb` folder and update the en variable `GRAPHDB_DATA_FILE` in `.env` file.

You can you generate the graphdb image:
```bash
docker-compose -f docker-compose-dev.yml build graphdb
#or
./dev.sh build graphdb
```

When you start API for the first time you will need to insert a user with maximum level because MongoDB starts empty so if you want to make protected requests you need a user.
To insert this user start containers first and then run: (replace `<vars>` with your values)
```bash
docker exec -it clav_mongo mongo m51-clav --eval 'db.users.insertOne({"name" : "<name>", "email" : "<email>", "entidade" : "ent_DGLAB", "internal" : true, "level" : 7, "local" : { "password" : "$2a$14$r2aUyscEREvZYmuVumNuoea40o8q4wmDMHt2nEsqvJkYiLSMshyYC" }, "nCalls" : 0, "notificacoes" : [ ] })'
#or
./dev.sh insertUser <name> <email>
```

The password is 'aaa'. You can after replace this password in API or interface.

### Writing code

#### Start API

To start API run:
```bash
docker-compose -f docker-compose-dev.yml up
#or
./dev.sh start
```

And if you want it detached (in background) run:
```bash
docker-compose -f docker-compose-dev.yml up -d
#or
./dev.sh startd
```

##### Volumes

The volume `clav-mongodb-data` have users, pedidos, pendentes, etc, info so you should not remove this one, only if you realy want.

The same applies to `clav-graphdb-data` wich have the graphdb data, ontology, LC, etc.

##### Ports

In `7779` port runs the protected API with Kong. (http://localhost:7779)

In `7778` port runs the unprotected API. (http://localhost:7778) Note: some requests can fail if it needs info from user token or from api key. In that cases you should use the protected version.

In `7777` port runs the auth service. (http://localhost:7777)

##### Logs

To see the logs of an container:
```bash
docker logs <container>
#or
docker logs <container> -f #follow log output

docker logs clav_server #for clav_server
docker logs clav_auth #for clav_auth
docker logs clav_kong #for kong
```

#### Code update

When code changes and you want to make this changes be present in container run:

- Code changes in `CLAV2018`:
```bash
docker stop clav_server
docker start clav_server

#or

./dev.sh restart clav_server
```

- Code changes in `CLAV-auth`:
```bash
docker stop clav_auth
docker start clav_auth

#or

./dev.sh restart clav_auth
```

#### Packages update

When `package.json` or `package-lock.json` changes to make this changes be present:

- For `clav_server` run:
```bash
docker stop clav_server
rm -r CLAV2018/node_modules
docker start clav_server

#or

./dev.sh updatePackages api
```

- For `clav_auth` run:
```bash
docker stop clav_auth
rm -r CLAV-auth/node_modules
docker start clav_auth

#or

./dev.sh updatePackages auth
```

The `start` command can take some time to run (it will install packages and start the Node.js server).

### Commits

After a commit in a submodule (`CLAV2018` or `CLAV-auth`), you will need to make one commit too in `docker-clav` in order to update the pointer of submodule.

After a new commit of another person in a submodule you need to run `git pull` in `docker-clav` (update pointer) and `git pull` in submodule folder to update content in that submodule.
