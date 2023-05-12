#!/usr/bin/env bash


# needed for crontab to access the X-window system
export XAUTHORITY=/home/pi/.Xauthority
export DISPLAY=:0


/home/pi/li/ddt/dt_install_python_ddh.sh
/home/pi/li/ddh/run_ddh.sh&
/home/pi/li/ddh/run_dds.sh&
