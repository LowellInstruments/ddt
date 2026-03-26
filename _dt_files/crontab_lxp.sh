#!/usr/bin/env bash


# get rid of possible nomachine update pop-ups
sudo kill -9 `ps -aux | grep NX | grep update | grep -v grep | awk '{print $2}'`


# check LXPanel is not consuming too much CPU / RAM
/home/pi/li/ddh/run_lxp.sh

