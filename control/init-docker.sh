#!/bin/bash

DO_TOKEN=$(cat /root/do_token)
rm /root/do_token

until docker-machine version; do
    echo "Waiting for docker-machine to be installed..."
    sleep 1
done

echo "Creating Docker droplet"

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token $DO_TOKEN \
    --digitalocean-image ubuntu-18-04-x64 \
    --digitalocean-region sgp1 \
    --digitalocean-backups=false \
    --engine-install-url "https://releases.rancher.com/install-docker/19.03.9.sh" \
    docker-nginx

echo "Docker droplet provisioned..."

echo "Setting env variables for terraform..."

echo "export SSH_P_KEY=/root/.ssh/id_rsa" >>/root/.bashrc
docker-machine env docker-nginx | grep DOCKER_HOST >>/root/.bashrc
docker-machine env docker-nginx | grep DOCKER_CERT_PATH >>/root/.bashrc
