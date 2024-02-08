#!/usr/bin/env bash


/home/pi/li/ddh/run_dds.sh&

# prevents mangled output at start
sleep 1

/home/pi/li/ddh/run_ddh.sh&


