# Pelias geocoder in a virtual box

This repository contains a Vagrant configuration to run the Pelias geocoder in a virtual machine.

## Overview

The goal of this repository is to create a VirtualBox virtual machine that contains a working offline [Pelias](https://www.pelias.io/) geocoder for Brazil.

The virtual machine is created using [Vagrant](https://developer.hashicorp.com/vagrant), from the [Vagrantfile](./Vagrantfile) provided in this repository.

## Installation

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

