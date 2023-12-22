#!/usr/bin/env bash


clear
echo; echo; echo;
echo '> running client for DDN API'


# see if we provided a password via command line
if [ $# -ne 1 ]; then
    echo 'error: missing password parameter'
    exit 1
fi


# run python DDN API client w/ provided password
python _dt_files/ddn_cli.py "$1"


echo; echo; echo

