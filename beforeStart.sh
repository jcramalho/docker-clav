#!/bin/bash

apt-get update && apt-get install -y openssl git

#gen dhparam
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#install external-auth plugin
luarocks install --server=https://luarocks.org/manifests/jcm300 external-auth

#gen domains list for kong db-less declarative config
domains_list=""
for domain in $DOMAINS
do
    domains_list+=$'\n        - '
    domains_list+=$domain
done

export DOMAINS_LIST=$domains_list
