#!/bin/bash
set -x

cd /home/vagrant/code/project
pelias elastic start
pelias elastic wait
pelias compose up
