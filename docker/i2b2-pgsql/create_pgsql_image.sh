#!/bin/bash
export I2B2_DATA_PGSQL_TAG=$1

docker builder prune -a -f 
docker images

echo "Starting postgres docker container.."
docker compose up i2b2-pg

if [ $? -eq 0 ]; then 
    echo "completed the scripts, building the docker image now.."
    sh dockerimage.sh
else
    echo "failed to commit the docker image"
    exit 1    
fi