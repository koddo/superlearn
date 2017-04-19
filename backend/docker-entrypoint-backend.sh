#!/usr/bin/env bash

if [[ -z "$*" ]]; then
    ~/theproject/_rel/hello_world_example/bin/hello_world_example foreground
else
    "$@"
fi



