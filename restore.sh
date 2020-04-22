restore(){
    docker run --rm -v $1:$2 -v $(pwd):/backup ubuntu bash -c "cd $2 && tar xvf /backup/$3.tar"
}

docker stop clav_nginx
docker stop clav_server

docker stop clav_graphdb
restore clav-graphdb-data /opt/graphdb/home/data/repositories clav_graphdb
docker start clav_graphdb

docker stop clav_mongo
restore clav-mongodb-data /data/db clav_mongo
docker start clav_mongo

docker start clav_server
docker start clav_nginx
