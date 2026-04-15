#!/bin/bash
set -x

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
chown 1000:1000 $CODE $DATA $BIN

cd $CODE
rm -rf docker;
git clone https://github.com/pelias/docker.git

cd docker

rm -f /usr/local/bin/pelias
ln -s "$(pwd)/pelias" /usr/local/bin/pelias

cd projects/portland-metro # replace with brazil when ready
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
# stop everything to avoid consuming resources when not needed
pelias compose down
pelias elastic stop

chmod +x $BIN/pelias_start.sh
chmod +x $BIN/pelias_stop.sh
cp $BIN/pelias.service /etc/systemd/system/
systemctl enable pelias.service

