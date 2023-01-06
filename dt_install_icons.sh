#!/usr/bin/env bash


F_DT=/home/pi/li/ddt
F_DA=/home/pi/li/ddh


clear
echo; echo; echo;

echo '> installing icon run DDH'
cp "$F_DT"/_dt_files/run_ddh_from_desktop.sh /home/pi/Desktop
echo '> installing icon script GPS'
cp "$F_DA"/scripts/run_gps_test_from_desktop.sh /home/pi/Desktop
echo '> installing icon script deploy loggers'
cp "$F_DA"/scripts/run_script_logger_do_deploy.sh /home/pi/Desktop

echo; echo; echo

