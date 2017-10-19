#!/usr/bin/env bash

if [[ -z "$*" ]]; then
    cp ~/secrets/dot.erlang.cookie ~/.erlang.cookie && \
        chmod 700 ~/.erlang.cookie && \
        make clean app rel && \
        ~/theproject/_rel/hello_world_example/bin/hello_world_example foreground
else
    "$@"
fi



