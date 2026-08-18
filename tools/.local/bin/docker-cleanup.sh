#!/bin/bash

# remove all stopped containers
docker ps -a -f status=exited -q | xargs --no-run-if-empty docker rm

# remove dangling images
docker image prune -f >/dev/null

# remove dangling volumes
docker volume prune -f >/dev/null
#docker ls -f dangling=true -q | xargs --no-run-if-empty docker volume rm
