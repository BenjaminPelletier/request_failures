#!/usr/bin/env bash

set -eo pipefail

docker build -t request_failures . || exit 1

docker network create --driver bridge request_failures_network || echo "request_failures_network already exists"

docker container rm -f webserver || echo "No existing webserver to remove"
docker container run --name webserver --network request_failures_network -p 8050:80 -d nginx

docker container rm -f client || echo "No existing client to remove"
export PYTHONUNBUFFERED=TRUE
docker container run --name client --network request_failures_network -it request_failures python main.py "http://webserver"
