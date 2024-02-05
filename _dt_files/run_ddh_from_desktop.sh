#!/usr/bin/env bash

echo; echo; echo

# we sleep a bit to prevent garbled output at start
/home/pi/li/ddh/run_ddh.sh&
sleep 1
/home/pi/li/ddh/run_dds.sh&

read -r
read -r
read -r