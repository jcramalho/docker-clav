#!/bin/bash

#flags
no_cron=false
folder=$(pwd)
while getopts ":nf:" o; do
    case "${o}" in
        n) no_cron=true;;
        f) folder=${OPTARG};;
        *) exit 0 ;;
    esac
done

#install dependency if necessary
if ! [ -x "$(command -v jq)" ]; then
	apt-get install -y jq
fi

#get raw certificates
json=$(docker exec -i clav_redis redis-cli <<<$'auth redisPass123\nGET "kong_acme:cert_key:clav-api5.ddns.net"')
json=${json:3:${#json}}

#parsing and writing certificates
parsed=$(echo $json | jq -r '.key')
echo "$parsed" > $folder/key.pem

parsed=$(echo $json | jq -r '.cert')
echo "$parsed" > $folder/fullchain.pem

if [ $no_cron = false ]; then
    #install dependency if necessary
    if ! [ -x "$(command -v crontab)" ]; then
        apt-get install -y cron
    fi

    line="10 0 * * * $(pwd)/getCerts.sh -n -f $folder >> /var/log/getCerts.log 2>&1"
    (crontab -l; echo "$line" ) | crontab -
fi
