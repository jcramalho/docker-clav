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

docker run -d --name kong \
    -v "$(pwd)/kong.conf:/etc/kong/kong.conf" \
    -v "$(pwd)/kong.yml:/usr/local/kong/declarative/kong.yml" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    kong-clav:1.0.0
