#!/bin/bash

#Trigger creation of certificates
for domain in $DOMAINS
do
    curl https://$domain -k
done
