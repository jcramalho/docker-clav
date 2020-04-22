backup(){
    docker run --rm --volumes-from $1 -v $(pwd):/backup ubuntu bash -c "cd $2 && tar cvf /backup/$1.tar ."
}

docker stop clav_nginx
docker stop clav_server

docker stop clav_graphdb
backup clav_graphdb /opt/graphdb/home/data/repositories
docker start clav_graphdb

docker stop clav_mongo
backup clav_mongo /data/db
docker start clav_mongo

docker start clav_server
docker start clav_nginx
