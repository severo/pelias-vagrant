# Pelias geocoder in a virtual box

This repository contains a Vagrant configuration to run the Pelias geocoder in a virtual machine.

## Overview

The goal of this repository is to create a VirtualBox virtual machine that contains a working offline [Pelias](https://www.pelias.io/) geocoder for Brazil.

The virtual machine is created using [Vagrant](https://developer.hashicorp.com/vagrant), from the [Vagrantfile](./Vagrantfile) provided in this repository.

If you want to use the Pelias geocoder for a different region, look at https://github.com/pelias/docker/tree/master/projects to find the region identifier, and replace "brazil" with the appropriate region in the Vagrantfile and in the bash scripts.

The creation requires two steps : a manual step in the host machine to download and prepare the data, and an automated step to create the virtual machine and provision it with the Pelias geocoder.

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

> ![IMPORTANT]
> Set the following environment variables, and ensure they are set during all the steps of this tutorial.

```bash
# Adapt to your needs
export PELIAS_PROJECT=portland-metro # smaller project. Try with it first, before trying with a bigger project like "brazil"
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

Get this repository and go to the project directory:

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

At this point, Pelias is running on your host machine. You can test that it's working by accessing the API:

- http://localhost:4000/v1/search?text=portland
- http://localhost:4000/v1/search?text=1901+Main+St
- http://localhost:4000/v1/reverse?point.lon=-122.650095&point.lat=45.533467
- http://localhost:4100/demo/#eng
- http://localhost:4200/-122.650095/45.533467
- http://localhost:4300/demo/#13/45.5465/-122.6351
- http://localhost:4400/parse?address=1730+ne+26th+ave,+portland,+or

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

For the "portland-metro" example, the provisioning process takes about 7 minutes, and the data copied to the virtual machine is about 6GB. The disk use is 17GB, inclding the 6GB of data.

## Start the virtual machine

> ![IMPORTANT]
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

> ![IMPORTANT]
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


## For Brazil

For Brazil, step 1 is:

```bash
export PELIAS_PROJECT=brazil
export PELIAS_DOCKER_DIR=~/tmp/docker
export VAGRANT_PROJECT_DIR=~/tmp/pelias-vagrant
cd ${PELIAS_DOCKER_DIR}/projects/${PELIAS_PROJECT}
${VAGRANT_PROJECT_DIR}/host.sh
```

Step 2 is:

```bash
export PELIAS_MACHINE_SIZE="100GB"
export PELIAS_PORT=6000
cd $VAGRANT_PROJECT_DIR
vagrant up --provision
```

Test:

```bash
curl -X POST "http://localhost:6000/v1/search?text=Rua%20do%20Ouvidor%2C%20Rio%20de%20Janeiro"
```
