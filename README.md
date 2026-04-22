# Pelias geocoder in a virtual box

This repository contains a Vagrant configuration to run the Pelias geocoder in a virtual machine.

## Overview

The goal of this repository is to create a VirtualBox virtual machine that contains a working offline [Pelias](https://www.pelias.io/) geocoder.

The virtual machine is created using [Vagrant](https://developer.hashicorp.com/vagrant), from the [Vagrantfile](./Vagrantfile) provided in this repository.

If you want to use the Pelias geocoder for a different region, look at https://github.com/pelias/docker/tree/master/projects to find the region identifier, and adapt the environment variables accordingly.

The creation requires two steps:
- one on the host machine to download and prepare the data,
- and one to create the virtual machine and provision it with the Pelias geocoder and data.

## Requirements

The instructions are for Ubuntu 25.10. Written on 15 April 2026.

Install VirtualBox:

```bash
sudo apt update
sudo apt install virtualbox
```

Install Vagrant (read https://developer.hashicorp.com/vagrant/install)

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install vagrant
```

Ensure that Vagrant is installed:

```bash
vagrant --version
vagrant --help
```

> [!IMPORTANT]
> Set the following environment variables, and ensure they are set during all the steps of this tutorial.

```bash
# Adapt to your needs
export PELIAS_PROJECT=portland-metro # smaller project. Try with it first, before trying with another region.
export PELIAS_DOCKER_DIR=~/tmp/docker
export VAGRANT_PROJECT_DIR=~/tmp/pelias-vagrant
```

Get the pelias/docker repository and create a symbolic link to the pelias command:

```bash
# get packages
sudo apt update
sudo apt install util-linux git curl

# clone the repository and go to the project directory
mkdir -p $PELIAS_DOCKER_DIR
git clone git@github.com:pelias/docker.git $PELIAS_DOCKER_DIR
sudo rm -f /usr/local/bin/pelias
sudo ln -s "$PELIAS_DOCKER_DIR/pelias" /usr/local/bin/pelias
```

Get this repository:

```bash
mkdir -p $VAGRANT_PROJECT_DIR
git clone git@github.com:severo/pelias-vagrant.git $VAGRANT_PROJECT_DIR
```

## Step 1: download and prepare the data on the host machine

The first step consists in preparing the data on the host machine. It's better to do this step before creating the virtual machine, because the host machine has more resources (CPU, RAM, disk space) than the virtual machine, and it will be faster to download and prepare the data.

On my machine (i9 32 cores, 64GB RAM, Ubuntu 25.10), the process takes about 10 minutes to download, prepare and import the data for the toy example 'portland-metro'. The longest step is the import into Elasticsearch.

By default, if you run the script, it will prepare the data for the "portland-metro" example:

```bash
cd ${PELIAS_DOCKER_DIR}/projects/${PELIAS_PROJECT}
${VAGRANT_PROJECT_DIR}/host.sh
```

Once done, for the portland-metro example, the ./data directory should contain the following subdirectories:

```
$ cd ${PELIAS_DOCKER_DIR}/projects/${PELIAS_PROJECT}; du -sh ./data/*
4.0K    ./data/blacklist
8.0K    ./data/csv
1.3G    ./data/elasticsearch
90M     ./data/interpolation
11M     ./data/placeholder
32M     ./data/transit
5.2G    ./data/whosonfirst
```

The logs are available for inspection:

```
$ cd ${PELIAS_DOCKER_DIR}/projects/${PELIAS_PROJECT}; du -sh *.log
4.0K    host_1_init.log
8.0K    host_2_download.log
4.0K    host_3_prepare.log
24K     host_4_import.log
4.0K    host_5_clean.log
60K     host_6_finish.log
4.0K    host.log
```

```
$ cat host.log
Starting Pelias geocoder setup
Step 1: initialization
Fri Apr 17 13:22:05 CEST 2026
Step 2: download
Fri Apr 17 13:22:23 CEST 2026
Step 3: prepare
Fri Apr 17 13:23:37 CEST 2026
Step 4: import
Fri Apr 17 13:28:32 CEST 2026
Step 5: clean
Fri Apr 17 13:32:08 CEST 2026
Step 6: finish
Fri Apr 17 13:32:08 CEST 2026
All steps completed
Fri Apr 17 13:32:34 CEST 2026
```

### Tests

At this point, Pelias is running on your host machine. You can test that it's working by accessing the API:

- http://localhost:4000/v1/search?text=portland
- http://localhost:4000/v1/search?text=1901+Main+St
- http://localhost:4000/v1/reverse?point.lon=-122.650095&point.lat=45.533467
- http://localhost:4100/demo/#eng
- http://localhost:4200/-122.650095/45.533467
- http://localhost:4300/demo/#13/45.5465/-122.6351
- http://localhost:4400/parse?address=1730+ne+26th+ave,+portland,+or

You can also try https://pelias.github.io/compare, configuring the local geocoder with http://localhost:4000. Note that you can also run the compare tool locally, see https://github.com/pelias/compare.

If you try the following address:

```
6700 NE Prescott St, Portland, OR 97218, United States
```

Pelias will return one point with the expected result, given by OpenAddresses: https://pelias.github.io/compare/#/v1/search?text=6700+NE+Prescott+St%2C+Portland%2C+OR+97218%2C+United+States&debug=1

For the following address:

```
1955, Northwest Raleigh Street, Slabtown, Northwest District, Portland, Multnomah County, Oregon, 97209, USA
```

Pelias gives 2 results with OpenAddresses and 3 results with OpenStreetMap, all with confidence 1 but not the same coordinates 🤷. Only two of them match the street number: https://pelias.github.io/compare/#/v1/search?text=1955%2C+Northwest+Raleigh+Street%2C+Slabtown%2C+Northwest+District%2C+Portland%2C+Multnomah+County%2C+Oregon%2C+97209%2C+USA&debug=1

### Detailed process

Once in the Portland project directory, and with the environment variables set, you can run the following commands to download the data, one at a time:

```
pelias download wof
pelias download oa
pelias download osm # beware: it downloads an archive from 2022!
```

At that point:

```
➜  portland-metro git:(master) ✗ du -sh data/*
4.0K    data/blacklist
41M     data/elasticsearch
443M    data/openaddresses
53M     data/openstreetmap
5.2G    data/whosonfirst
```

Then prepare the data:

```
pelias prepare polylines # only for OSM, creates data/polylines/extract.0sv
pelias prepare placeholder # only uses WOF? creates data/placeholder/store.sqlite3 and data/placeholder/wof.extract
pelias prepare interpolation # uses prepared polylines, then openadresses and openstreetmap, creates data/interpolation/address.db, data/interpolation/street.db and other temporary? files
```

At that point:

```
➜  portland-metro git:(master) ✗ du -sh data/*
4.0K    data/blacklist
41M     data/elasticsearch
114M    data/interpolation
443M    data/openaddresses
53M     data/openstreetmap
17M     data/placeholder
3.8M    data/polylines
8.0K    data/tiger
5.2G    data/whosonfirst
```

Import to Elasticsearch:

```
pelias import wof
pelias import oa # <- take some time (160s for Portland)
pelias import osm
pelias import polylines
```

Then start the containers:

```
pelias compose up
```

The running containers are:

```
➜  portland-metro git:(master) ✗ pelias compose ps
NAME                   IMAGE                          COMMAND                  SERVICE         CREATED          STATUS          PORTS
pelias_api             pelias/api:master              "./bin/start"            api             42 seconds ago   Up 40 seconds   0.0.0.0:4000->4000/tcp
pelias_elasticsearch   pelias/elasticsearch:7.17.27   "/bin/tini -- /usr/l…"   elasticsearch   20 minutes ago   Up 20 minutes   127.0.0.1:9200->9200/tcp, 127.0.0.1:9300->9300/tcp
pelias_interpolation   pelias/interpolation:master    "./interpolate serve…"   interpolation   42 seconds ago   Up 40 seconds   127.0.0.1:4300->4300/tcp
pelias_libpostal       pelias/libpostal-service       "/bin/wof-libpostal-…"   libpostal       42 seconds ago   Up 40 seconds   127.0.0.1:4400->4400/tcp
pelias_pip-service     pelias/pip-service:master      "./bin/start"            pip             42 seconds ago   Up 40 seconds   127.0.0.1:4200->4200/tcp
pelias_placeholder     pelias/placeholder:master      "./cmd/server.sh"        placeholder     42 seconds ago   Up 40 seconds   127.0.0.1:4100->4100/tcp
```

and the logs should not contain errors:

```
pelias compose logs
```


### Uninstall

If you want to uninstall and clean the data, you can run the following commands:

```bash
# assuming the current directory is the project directory (e.g. projects/portland-metro)
cd ${PELIAS_DOCKER_DIR}/projects/${PELIAS_PROJECT}
pelias compose down
git restore .env
rm ./*.log
rm -rf ./data
```

## Step 2: create the virtual machine and provision it with the Pelias geocoder

Once step 1 is done, the data is ready and Pelias is running on your host machine. Ensure it's working before starting step 2.

Step 2 is to create the virtual machine and provision it with the Pelias geocoder. The provisioning process will copy the data from the host machine to the virtual machine, and start the Pelias geocoder inside the virtual machine.

Run the following command to create the virtual machine and provision it with the Pelias geocoder:

```bash
export PELIAS_MACHINE_SIZE="20GB" # adapt to your needs (at least 15GB for Pelias + the data), to ensure the data can be copied to the machine. The default value is 8GB, which is not enough for the "portland-metro" example.
export PELIAS_PORT=5000
cd $VAGRANT_PROJECT_DIR
vagrant up --provision
```

For the "portland-metro" example, the provisioning process takes about 7 minutes, and the data copied to the virtual machine is about 6GB. The disk use is 17GB, including the 6GB of data.

## Start the virtual machine

> [!IMPORTANT]
> The environment variables PELIAS_MACHINE_SIZE, PELIAS_DOCKER_DIR, PELIAS_PROJECT and PELIAS_PORT must be set before running any of the commands below.

Any time you want to start the virtual machine, run:

```bash
vagrant up
```

See status:

```bash
vagrant status
```

Access the machine via SSH (no need to log in, as Vagrant takes care of that):

```bash
vagrant ssh
```

You can also access the virtual machine directly via VirtualBox, and log in with the username "vagrant" and the password "vagrant".

## Stop the virtual machine

> [!IMPORTANT]
> The environment variables PELIAS_MACHINE_SIZE, PELIAS_DOCKER_DIR and PELIAS_PROJECT must be set before running any of the commands below.

To stop the virtual machine, run:

```bash
vagrant halt
```

## Test the virtual machine


- http://localhost:5000/v1/search?text=portland
- http://localhost:5000/v1/search?text=1901+Main+St
- http://localhost:5000/v1/reverse?point.lon=-122.650095&point.lat=45.533467


TODO: how to access these other services from :5000? See https://github.com/pelias/documentation?tab=readme-ov-file#endpoint-descriptions
- http://localhost:4100/demo/#eng
- http://localhost:4200/-122.650095/45.533467
- http://localhost:4300/demo/#13/45.5465/-122.6351
- http://localhost:4400/parse?address=1730+ne+26th+ave,+portland,+or
