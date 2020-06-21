#!/bin/bash

apt-get update && apt-get install -y git gettext

#install external-auth plugin
luarocks install --server=https://luarocks.org/manifests/jcm300 external-auth

#create final db-less declarative config
envsubst '$$API_VERSION $$API_HOST $$SERVER_AUTH_HOST' < /usr/local/kong/declarative/kong.yml.template > /usr/local/kong/declarative/kong.yml
