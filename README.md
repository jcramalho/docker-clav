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

## Use already built docker images

If you want to use the already built images you only need to run `docker-compose up`.

## Some notes

You can if you want, change the variables in `.env` file.

## Backup and Restore scripts

This scripts allow to backup and restore the volumes of the docker containers created with the docker-compose files. The backup script produces two tar files with the volumes data. The restore script use this two tar files to restore.

If you have the containers running and you want to migrate you only need to:
- Run backup script
- Move the backup files to the new location
- Create the containers building the images or using the already ones built in the new location
- Run the restore script in the new location

## Development guide

### Preparation

First you should install the requirements.

Then you clone the git rep, change to `kong` branch and obtain the submodules content:

```bash
git clone https://github.com/jcramalho/docker-clav.git
cd docker-clav
git checkout kong
git submodule update --init

cd CLAV2018
git checkout kong

cd ..

cd CLAV-auth
git checkout master

cd ..
```

After that you need to get an GraphDB distribution, the standalone server version, (http://graphdb.ontotext.com/) and put them in the `graphdb` folder.

Change the GraphDB version in the env variable `GRAPHDB_VERSION` in `.env` file. This version should be the same as that comes with the name file (ex: `graphdb-free-8.11.0-dist.zip` as `free-8.11.0` as version)

If you have an new ontology version, put it in the `graphdb` folder and update the env variable `GRAPHDB_DATA_FILE` in `.env` file.

You can now generate the `graphdb` image:
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

In order to changes appear in containers you should write the code in `CLAV2018` folder for API and in `CLAV-auth` folder for auth service.

#### Start

To start the containers run:
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

The volume `clav-mongodb-data` have users, pedidos, pendentes, etc, info so you should not remove this one, only if you really want.

The same applies to `clav-graphdb-data` which have the GraphDB data, ontology, LC, etc.

##### Ports

In `7779` port runs the protected API with Kong. (http://localhost:7779)

In `7778` port runs the unprotected API. (http://localhost:7778) Note: some requests can fail if it needs info from user token or from api key. In that cases you should use the protected version.

In `7777` port runs the auth service. (http://localhost:7777)

In `7200` port runs GraphDB Workbench. (http://localhost:7200)

If you need a Mongo shell you can get one running: (`clav_mongo` container need to be running)
```bash
docker exec -it clav_mongo mongo
#or
./dev.sh mongo
```

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

If you want to make the code changes be present in container run:

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

### Pulls and Pushs

The current submodules uses HTTPS instead of SSH. If you want to use SSH you need to run:
```
#assuming you are in the docker-clav folder

cd CLAV2018
git remote set-url origin git@github.com:jcramalho/CLAV2018.git

cd ..

cd CLAV-auth
git remote set-url origin git@github.com:jcramalho/CLAV-auth.git
```

**Do not change the submodules remote repository in `docker-clav`. Do not edit `.gitmodules` file in `docker-clav` folder. And if you change through `git config` do not run `git submodule sync`.**

### `dev.sh` script

```
Usage: ./dev.sh {start|startd|stop|restart|updatePackages|build|rebuild|insertUser|mongo|help}
    start                       Start dev containers
    startd                      Start dev containers in background
    stop                        Stop dev containers
    restart <container>         Restart (stop and start) container
    updatePackages {auth|api}   Restart and update packages
    build                       Build images
    build <service1> ...        Build image for service(s)
    rebuild                     Rebuild (no-cache) images
    rebuild <service1> ...      Rebuild (no-cache) image for service(s)
    insertUser <name> <email>   Insert user in MongoDB running container
    mongo                       Opens an Mongo Shell
    help                        Help
```
