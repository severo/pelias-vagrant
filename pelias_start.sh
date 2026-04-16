#!/bin/bash
set -x

cd /home/vagrant/code/docker/projects/brazil
pelias elastic start
pelias elastic wait
pelias compose up
