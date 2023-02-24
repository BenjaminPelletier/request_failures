#!/usr/bin/env bash

set -eo pipefail

docker build -t request_failures . || exit 1

docker container rm -f webserver || echo "No existing webserver to remove"
docker container run --name webserver -p 8050:80 -d nginx

docker container rm -f client || echo "No existing client to remove"
export PYTHONUNBUFFERED=TRUE
docker container run --name client --add-host host.docker.internal:host-gateway -it request_failures python main.py "http://host.docker.internal:8050"
