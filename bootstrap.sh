#!/bin/bash
set -x

apt-get update
apt-get install -y git parted
parted ---pretend-input-tty /dev/sda 'unit % resizepart 3 yes 100%'
resize2fs /dev/sda3

# See https://github.com/pelias/docker/
HOME=/home/vagrant
CODE=$HOME/code
DATA=$HOME/data
BIN=$HOME/bin

mkdir -p $CODE $DATA $BIN
chown 1000:1000 $CODE $DATA $BIN

cd $CODE
rm -rf docker;
git clone https://github.com/pelias/docker.git

cd docker
git checkout brazil

rm -f /usr/local/bin/pelias
ln -s "$(pwd)/pelias" /usr/local/bin/pelias

cd projects/brazil
sed -i '/DATA_DIR/d' .env
echo "DATA_DIR=$DATA" >> .env
pelias compose pull

chmod +x $BIN/pelias_start.sh
chmod +x $BIN/pelias_stop.sh
cp $HOME/bin/pelias.service /etc/systemd/system/
systemctl enable pelias.service
