#!/bin/bash

help(){
    echo $"Usage: $0 {start|startd|stop|restart|updatePackages|build|rebuild|insertUser|help}"
    echo "    start                       Start dev containers"
    echo "    startd                      Start dev containers in background"
    echo "    stop                        Stop dev containers"
    echo "    restart <container>         Restart (stop and start) container"
    echo "    updatePackages {auth|api}   Restart and update packages"
    echo "    build                       Build images"
    echo "    build <service1> ...        Build image for service(s)"
    echo "    rebuild                     Rebuild (no-cache) images"
    echo "    rebuild <service1> ...      Rebuild (no-cache) image for service(s)"
    echo "    insertUser <name> <email>   Insert user in MongoDB running container"
    echo "    mongo                       Opens an Mongo Shell"
    echo "    help                        Help"
}

set -e

SCRIPT_HOME="$( cd "$( dirname "$0" )" && pwd )"
cd $SCRIPT_HOME

case "$1" in
  start)
      docker-compose -f docker-compose-dev.yml up
    ;;
  startd)
      docker-compose -f docker-compose-dev.yml up -d
    ;;
  stop)
      docker-compose -f docker-compose-dev.yml stop
    ;;
  restart)
      if [ "$#" -eq "2" ]; then
        docker stop $2
        docker start $2
      else
        echo $"Usage: $0 $1 <container>"
        RETVAL=1
      fi
    ;;
  updatePackages)
      case "$2" in
        auth)
            docker stop clav_auth
            sudo rm -r CLAV-auth/node_modules
            docker start clav_auth
          ;;
        api)
            docker stop clav_server
            sudo rm -r CLAV2018/node_modules
            docker start clav_server
          ;;
        *)
          echo $"Usage: $0 $1 {auth|api}"
          RETVAL=1
      esac
    ;;
  build)
      shift
      docker-compose -f docker-compose-dev.yml build $@
    ;;
  rebuild)
      shift
      docker-compose -f docker-compose-dev.yml build --no-cache $@
    ;;
  insertUser)
      if [ "$#" -eq "3" ]; then
        docker exec -it clav_mongo mongo m51-clav --eval 'db.users.insertOne({"name" : "'$2'", "email" : "'$3'", "entidade" : "ent_DGLAB", "internal" : true, "level" : 7, "local" : { "password" : "$2a$14$r2aUyscEREvZYmuVumNuoea40o8q4wmDMHt2nEsqvJkYiLSMshyYC" }, "nCalls" : 0, "notificacoes" : [ ] })'
      else
        echo $"Usage: $0 $1 <name> <email>"
        RETVAL=1
      fi
    ;;
   mongo)
      docker exec -it clav_mongo mongo
    ;;
   help)
      help $0
    ;;
  *)
    help $0
    RETVAL=1
esac

cd - > /dev/null
