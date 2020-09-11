#!/bin/bash

set -o errexit



source /opt/cloud/environment-docker.sh


/opt/jobber/docker-entrypoint.sh "$@"
