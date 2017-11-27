#!/usr/bin/env bash

docker run --rm \
    --volume superlearn_pgdata:/var/lib/postgresql/data \
    --volume $(pwd):/mnt \
    debian \
    tar cvfz /mnt/superlearn--$(date '+%Y-%m-%d--%H-%M-%S')--pgdata.tgz /var/lib/postgresql/data

tar cvfz superlearn--$(date '+%Y-%m-%d--%H-%M-%S')--migration-logs.tgz database/logs_superlearn_postgres 

