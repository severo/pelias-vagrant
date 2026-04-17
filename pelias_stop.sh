#!/bin/bash
set -x

cd /home/vagrant/code/project
pelias compose down
pelias elastic stop
