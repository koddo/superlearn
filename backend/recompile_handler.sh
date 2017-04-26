#!/usr/bin/env bash

HANDLER=$1
CMD="
code:purge($HANDLER),
compile:file(\"/home/theuser/theproject/src/$HANDLER\", [{outdir, \"/home/theuser/theproject/ebin/\"}, debug_info]),
code:load_abs(\"/home/theuser/theproject/ebin/$HANDLER\").
"

echo $CMD | erl_call -c hello_world_example -name hello_world_example@$(hostname) -e
echo
