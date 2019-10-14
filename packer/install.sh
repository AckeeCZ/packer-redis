#!/bin/bash

version=${REDIS_VER:=4.0}

sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y wget software-properties-common lsb-release perl curl build-essential tcl nmap htop pigz ncdu libhiredis0.13
DEBIAN_FRONTEND=noninteractive sudo apt-get -y dist-upgrade

cd /tmp
curl -O http://download.redis.io/releases/redis-${version}.tar.gz

tar xzvf redis-${version}.tar.gz
cd redis-${version}/

make
make test
sudo make install

sudo mkdir /etc/redis

sudo cp /tmp/redis-${version}/redis.conf /etc/redis

sudo sed -i 's/supervised no/supervised systemd/g' /etc/redis/redis.conf
sudo sed -i 's/dir .\//dir \/var\/lib\/redis/g' /etc/redis/redis.conf
sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf

sudo adduser --system --group --no-create-home redis
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis

sudo mv /tmp/redis.service /etc/systemd/system/

#sudo mkdir /etc/systemd/system/mongod.service.d
#sudo mv /tmp/systemd-override.conf /etc/systemd/system/mongod.service.d/override.conf

sudo systemctl enable redis.service