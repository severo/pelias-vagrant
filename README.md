# Pelias geocoder in a virtual box

This repository contains a Vagrant configuration to run the Pelias geocoder in a virtual machine.

## Overview

The goal of this repository is to create a VirtualBox virtual machine that contains a working offline [Pelias](https://www.pelias.io/) geocoder for Brazil.

The virtual machine is created using [Vagrant](https://developer.hashicorp.com/vagrant), from the [Vagrantfile](./Vagrantfile) provided in this repository.

## Requirements

The instructions are for Ubuntu 25.10. Written on 15 April 2026.

Install VirtualBox:

```bash
sudo apt update;
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

## Create the virtual machine

The first time, run the following command to create the virtual machine and provision it with the Pelias geocoder:

```bash
vagrant up
```

If you're provisioning the machine with the "portland-metro" pelias project, the prvisioning process will take about one hour (install, downlad the data, create the indexes).

For Brazil, it will take much longer, as the data is much larger. The provisioning process will take about xxxx hours, as it needs to download and import the data for the whole country.

TODO:

- how to update the Pelias data? (vagrant ssh, then run the appropriate commands inside the virtual machine?)

## Start the virtual machine

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

TODO:

- which is the user and password to log in to the virtual machine from VirtualBox? https://portal.cloud.hashicorp.com/vagrant/discover/cloud-image/ubuntu-24.04

## Stop the virtual machine

To stop the virtual machine, run:

```bash
vagrant halt
```

## Test the virtual machine

TODO: This does not work:

```bash
curl -X POST "http://192.168.56.10:4000/v1/search?text=Rua%20do%20Ouvidor%2C%20Rio%20de%20Janeiro" -H "accept: application/json"
```
