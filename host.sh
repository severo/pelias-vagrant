#!/bin/bash
set -x
shopt -s extglob

function host_init {
    # prepare the data directory and update the .env file
    mkdir -p "./data"
    sed -i '/DATA_DIR/d' .env
    echo "DATA_DIR=./data" >> .env

    # pull the latest images
    pelias compose pull

    # start the elasticsearch container and wait for it to be ready
    pelias elastic start
    pelias elastic wait
    pelias elastic create
}

function host_clean {
    # The numbers in this snippet below are rough estimates for a full planet build.
    du -sh ./data/*

    # These folders can be entirely deleted after the import into elastic search
    rm -rf ./data/openaddresses #(~43GB)
    rm -rf ./data/tiger #(~13GB)
    rm -rf ./data/openstreetmap #(~46GB)
    rm -rf ./data/polylines #(~2.7GB)

    # Within the content of the "interpolation" folder (~176GB) we must
    # preserve "street.db" (~7GB) and "address.db" (~25GB), the rest can be deleted
    cd ./data/interpolation
    rm -rf -- !("street.db"|"address.db")
    cd -

    # Within the content of the "placeholder" folder (~1.4GB), we must
    # preserve the "store.sqlite3" (~0.9GB) file, the rest can be deleted
    cd ./data/placeholder
    rm -rf -- !("store.sqlite3")
    cd -

    du -sh ./data/*
}

function host_finish {
    # start the API and other containers
    pelias compose up

    # test the API after waiting for the containers to fully boot
    sleep 10
    pelias test run
}

function host_main {
    # print and copy to log file
    echo "Starting Pelias geocoder setup" | tee host.log
    echo "Step 1: initialization" | tee -a host.log
    date | tee -a host.log

    # run the initialization script, and capture the output to a file for later reference
    host_init 2>&1 | tee host_1_init.log

    echo "Step 2: download" | tee -a host.log
    date | tee -a host.log

    # run the download script, and capture the output to a file for later reference
    # download the data
    pelias download all 2>&1 | tee host_2_download.log

    echo "Step 3: prepare" | tee -a host.log
    date | tee -a host.log

    # run the prepare script, and capture the output to a file for later reference
    pelias prepare all 2>&1 | tee host_3_prepare.log

    echo "Step 4: import" | tee -a host.log
    date | tee -a host.log

    # run the import script, and capture the output to a file for later reference
    pelias import all 2>&1 | tee host_4_import.log

    echo "Step 5: clean" | tee -a host.log
    date | tee -a host.log

    # run the clean script, and capture the output to a file for later reference
    host_clean 2>&1 | tee host_5_clean.log

    echo "Step 6: finish" | tee -a host.log
    date | tee -a host.log

    # run the finish script, and capture the output to a file for later reference
    host_finish 2>&1 | tee host_6_finish.log

    echo "All steps completed" | tee -a host.log
    date | tee -a host.log
}

host_main
