#!/bin/bash

b_flag='false'

while getopts 'b' flag; do
    case ${flag} in
        b) b_flag='true' ;;
    esac
done

docker stop kong
docker rm kong

if [[ $b_flag == 'true' ]]; then 
    docker build -t kong-clav:1.0.0 . --no-cache
fi

ngrok http localhost:8000 --log=stdout > /dev/null &

NGROK_URL=""
while [ -z $NGROK_URL ]
do
    NGROK_URL=$(curl --silent http://127.0.0.1:4040/api/tunnels | grep -Po --color 'https://[0-9a-z]+\.ngrok\.io')
done

export API_VERSION="v2"
export EMAIL="jcm300@live.com.pt"
export DOMAINS=$NGROK_URL

domains_list=""
for domain in $DOMAINS
do
    domains_list+=$'\n        - '
    domains_list+=$(echo $domain | sed -r 's/^https?:\/\///')
done

export DOMAINS_LIST=$domains_list

envsubst '$$API_VERSION $$DOMAINS $$EMAIL $$DOMAINS_LIST' < kong.yml.template > kong.yml

docker run -d --name kong \
    -v "$(pwd)/kong.conf:/etc/kong/kong.conf" \
    -v "$(pwd)/kong.yml:/usr/local/kong/declarative/kong.yml" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    kong-clav:1.0.0
