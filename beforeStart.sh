#!/bin/bash

CERTS_FOLDER=${1:-/etc/nginx/acme.sh}

if [ ! -d $CERTS_FOLDER ]; then
    mkdir -p $CERTS_FOLDER
fi

apt-get update && apt-get install -y openssl sudo

#gen a self-signed certificate only to boot nginx
openssl req -batch -sha256 -x509 -nodes -days 1 -subj "/C=PT/ST=Denial/L=Portugal/O=CLAV/CN=localhost" -newkey rsa:2048 -keyout $CERTS_FOLDER/key.pem -out $CERTS_FOLDER/fullchain.pem

#gen dhparam example, only to boot nginx
openssl dhparam -out $CERTS_FOLDER/dhparam.pem 1024
