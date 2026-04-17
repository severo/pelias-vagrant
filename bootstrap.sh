#!/bin/bash
set -x

# set the password for the vagrant user
echo "vagrant:vagrant" | sudo chpasswd

apt update
apt upgrade -y
apt install -y git util-linux

# See https://github.com/pelias/docker/
HOME=/home/vagrant
CODE=$HOME/code
DATA=$HOME/data
BIN=$HOME/bin

mkdir -p $CODE $DATA $BIN
chown vagrant:vagrant $CODE $DATA $BIN

cd $CODE
rm -rf docker;
git clone https://github.com/pelias/docker.git

cd docker

rm -f /usr/local/bin/pelias
ln -s "$(pwd)/pelias" /usr/local/bin/pelias

cp -r projects/${PELIAS_PROJECT:-portland-metro} $CODE/project/
sed -i '/DATA_DIR/d' .env
echo "DATA_DIR=$DATA" >> .env
pelias compose pull

chmod +x $BIN/pelias_start.sh
chmod +x $BIN/pelias_stop.sh
cp $BIN/pelias.service /etc/systemd/system/
systemctl enable pelias.service
