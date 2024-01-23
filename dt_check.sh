#!/usr/bin/env bash


FOL=/home/pi/li/ddt
if [ "$(pwd)" != $FOL ]; then
    echo "error dt_check: working_dir should be $FOL"
    exit 1
fi
