backup(){
    sudo docker run --rm --volumes-from $1 -v $(pwd):/backup ubuntu bash -c "cd $2 && tar cvf /backup/$1.tar ."
}

sudo docker stop clav_server

sudo docker stop clav_graphdb
backup clav_graphdb /opt/graphdb/home/data/repositories
sudo docker start clav_graphdb

sudo docker stop clav_mongo
backup clav_mongo /data/db
sudo docker start clav_mongo

sudo docker start clav_server
