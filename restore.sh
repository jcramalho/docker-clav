restore(){
    sudo docker run --rm -v $1:$2 -v $(pwd):/backup ubuntu bash -c "cd $2 && tar xvf /backup/$3.tar"
}

sudo docker stop clav_server

sudo docker stop clav_graphdb
restore clav-graphdb-data /opt/graphdb/home/data/repositories clav_graphdb
sudo docker start clav_graphdb

sudo docker stop clav_mongo
restore clav-mongo-data /data/db clav_mongo
sudo docker start clav_mongo

sudo docker start clav_server
