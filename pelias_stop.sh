#!/bin/bash
set -x

cd /home/vagrant/code/docker/projects/brazil
pelias compose down
pelias elastic stop
