FROM kong:2.0.4-ubuntu

USER root

RUN apt-get update
RUN apt-get install -y git

RUN luarocks install --server=https://luarocks.org/manifests/jcm300 external-auth

USER kong
