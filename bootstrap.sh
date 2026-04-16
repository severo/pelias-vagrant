#!/bin/bash
set -x

# set the password for the vagrant user
echo "vagrant:vagrant" | sudo chpasswd

apt update
apt install -y git util-linux
# apt install -y git parted util-linux
# parted ---pretend-input-tty /dev/sda 'unit % resizepart 3 yes 100%'
# resize2fs /dev/sda3

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

cd projects/brazil
sed -i '/DATA_DIR/d' .env
echo "DATA_DIR=$DATA" >> .env
pelias compose pull

# run the full import process on first boot
pelias elastic start
pelias elastic wait
pelias elastic create
pelias download all
pelias prepare all
pelias import all
pelias compose up
# optionally run tests after waiting for containers to fully boot
sleep 10
pelias test run

chmod +x $BIN/pelias_start.sh
chmod +x $BIN/pelias_stop.sh
cp $BIN/pelias.service /etc/systemd/system/
systemctl enable pelias.service

