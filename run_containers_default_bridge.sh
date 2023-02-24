#!/usr/bin/env bash

set -eo pipefail

docker build -t request_failures . || exit 1

docker container rm -f webserver || echo "No existing webserver to remove"
docker container run --name webserver -p 8050:80 -d nginx
WEBSERVER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' webserver)

docker container rm -f client || echo "No existing client to remove"
export PYTHONUNBUFFERED=TRUE
docker container run --name client -it request_failures python main.py "http://${WEBSERVER_IP}"
