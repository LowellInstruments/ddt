#!/usr/bin/env bash

MY_FLAG=/tmp/ran_script_from_rc_local.sh

rm $MY_FLAG

echo "this script rans after rc_local and resides in /li"

touch $MY_FLAG