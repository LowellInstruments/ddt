#!/usr/bin/bash


source /home/pi/li/ddh/scripts/utils.sh
clear


_S="[ DDU ] killing DDH"
_pb "$_S"
killall main_ddh
killall main_dds
killall main_ddh_controller
killall main_dds_controller
_e $? "$_S"


_pg "[ DDU ] killing ddh done"
