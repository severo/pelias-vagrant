#!/bin/bash
set -x

cd /home/vagrant/code/docker/projects/portland-metro # replace with brazil when ready
pelias compose down
pelias elastic stop
