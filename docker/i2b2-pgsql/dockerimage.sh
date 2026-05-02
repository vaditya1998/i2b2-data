#!/bin/bash

# ==============================================================================
# Script Name: dockerimage.sh
# Description: Commits the running Postgres container to an image and pushes it.
# ==============================================================================

set -eu

docker commit i2b2-pg "${docker_username}/${docker_reponame}:i2b2-data-pgsql-container-commit-${I2B2_DATA_PGSQL_TAG}-${date}"
echo "Completed committing the docker image."

sed -i "s#image_tag#${docker_username}/${docker_reponame}:i2b2-data-pgsql-container-commit-${I2B2_DATA_PGSQL_TAG}-${date}#g" Dockerfile

docker images 
docker build -t "${docker_username}/${docker_reponame}:i2b2-data-pgsql_${I2B2_DATA_PGSQL_TAG}" .
docker push "${docker_username}/${docker_reponame}:i2b2-data-pgsql_${I2B2_DATA_PGSQL_TAG}"

#for testing with latest image
# docker tag "${docker_username}/${docker_reponame}:i2b2-data-pgsql-${I2B2_DATA_PGSQL_TAG}-${date}" "${docker_username}/${docker_reponame}:i2b2-data-pgsql_latest"
# docker push "${docker_username}/${docker_reponame}:i2b2-data-pgsql_latest"

# docker buildx build --platform linux/amd64 -t "${docker_username}/${docker_reponame}:i2b2-data-pgsql-${I2B2_DATA_PGSQL_TAG}-${date}" --push . #multi-platform is not possible, as we are commiting the base docker image.
echo "Docker image built successfully."
