# Development Manual

## Before start

```bash
git clone https://github.com/jcm300/docker-clav.git
cd docker-clav
git checkout kong
git submodule update --init
```

Get an GraphDB distribution (zip file) and put it at graphdb folder.

## Start

```bash
docker-compose -f docker-compose-dev.yml up
```

If you want start detached (in background) run:
```bash
docker-compose -f docker-compose-dev.yml up -d
```

## Insert a user with maximum level

The MongoDB starts empty so if you want to make protected requests you need a user.
Is necessary to start containers first. Then run: (replace <vars> with your values)

```bash
docker exec -it clav_mongo mongo m51-clav --eval 'db.users.insertOne({"name" : "<name>", "email" : "<email>", "entidade" : "ent_DGLAB", "internal" : true, "level" : 7, "local" : { "password" : "$2a$14$r2aUyscEREvZYmuVumNuoea40o8q4wmDMHt2nEsqvJkYiLSMshyYC" }, "nCalls" : 0, "notificacoes" : [ ] })'
```

The password is 'aaa'. You can after replace this password in API or interface.

## When CLAV2018 code changes to make this changes be present in container run

```bash
docker stop clav_server
docker start clav_server
```

## When CLAV-auth code changes to make this changes be present in container run

```bash
docker stop clav_auth
docker start clav_auth
```

## When package.json or package-lock.json changes to make changes be present run

For clav_server:
```bash
docker stop clav_server
rm -r CLAV2018/node_modules
docker start clav_server
```

For clav_auth:
```bash
docker stop clav_auth
rm -r CLAV-auth/node_modules
docker start clav_auth
```

The last command can take some time to run (it will install packages and start the nodejs server)

## To see logs of a container run
```bash
docker logs <container>

docker logs clav_server #for clav_server
```

## Commits

After a commit in a submodule (CLAV2018 or CLAV-auth), you will need to make one commit too in docker-clav in order to update the pointer of submodule

After a new commit of another person in a submodule you need to run `git pull` to update content in that submodule.

## Volumes

The volume clav-mongodb-data have users info so you should not remove this one, only if you realy want.

The same applies to clav-graphdb-data wich have the graphdb data, so ontology, LC, etc.
