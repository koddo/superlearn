#!/usr/bin/env bash

FILENAME="$(basename $1)"
ABSPATH="$(readlink -f $1)"

# docker-compose stop database
# docker rm --volumes superlearn_database_1
# docker volume rm superlearn_pgdata
# docker volume create --name=superlearn_pgdata
docker run --rm \
    --volume superlearn_pgdata:/var/lib/postgresql/data \
    --volume "$ABSPATH":"/$FILENAME" \
    debian \
    tar xvfz "/$FILENAME" \
    --directory /var/lib/postgresql/data \
    --strip-components 4


