#!/bin/bash
set -x

cd /home/vagrant/code/docker/projects/portland-metro # replace with brazil when ready
pelias elastic start
pelias elastic wait
pelias compose up
