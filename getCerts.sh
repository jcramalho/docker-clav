#!/bin/bash

#flags
no_cron=false
folder=$(pwd)
domain="*"
while getopts ":nf:d:" o; do
    case "${o}" in
        n) no_cron=true;;
        f) folder=${OPTARG};;
        d) domain=${OPTARG};;
        *) exit 0 ;;
    esac
done

#install dependency if necessary
if ! [ -x "$(command -v jq)" ]; then
	apt-get install -y jq
fi

#get raw certificates
comm="auth redisPass123\nGET kong_acme:cert_key:${domain}"
json=$(echo -e "$comm" | docker exec -i clav_redis redis-cli)
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

    line="10 0 * * * $(pwd)/getCerts.sh -n -f $folder -d $domain >> /var/log/getCerts.log 2>&1"
    (crontab -l; echo "$line" ) | crontab -
fi
