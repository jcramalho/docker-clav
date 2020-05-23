#!/bin/bash

usage(){
    echo "USAGE: ./getCerts.sh -d <domain>"
    echo "    -d    <domain>    Domain of certificates. REQUIRED"
    echo "    -f    <folder>    Folder where the certificates will be stored"
    echo "    -n                Flag that indicates to not add cronjob in crontabs"
    echo "    -h                Help"
}

#flags
no_cron=false
folder=$(pwd)
domain=""
while getopts ":nf:d:h" o; do
    case "${o}" in
        n) no_cron=true;;
        f) folder=${OPTARG};;
        d) domain=${OPTARG};;
        h) usage
           exit 0 ;;
        *) usage
           exit 1 ;;
    esac
done

#check if domain was inserted
if [ -z "$domain" ]; then
    usage
    exit 1
fi

#install dependency if necessary
if ! [ -x "$(command -v jq)" ]; then
    if ! [ -x "$(command -v apt-get)" ]; then
        echo "ERROR: Missing dependency jq..."
        exit 1
    else
	    apt-get install -y jq
    fi
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
        if ! [ -x "$(command -v apt-get)" ]; then
            echo "ERROR: Missing dependency crontab."
            echo "       Cronjob not inserted. This script will not run periodically."
            exit 1
        else
            apt-get install -y cron
        fi
    fi

    line="10 0 * * * $(pwd)/getCerts.sh -n -f $folder -d $domain >> /var/log/getCerts.log 2>&1"
    (crontab -l; echo "$line" ) | crontab -
fi
