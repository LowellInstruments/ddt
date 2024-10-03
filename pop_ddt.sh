#!/usr/bin/bash



source /home/pi/li/ddh/scripts/utils.sh
clear


_S="[ DDU ] updating DDT"
_pb "$_S"
cd "$FOL_DDT" && git reset --hard && git pull
_e $? "$_S"


_S="[ DDU ] creating new aliases for DDT"
_pb "$_S"
cd "$FOL_DDT" && ./dt_install_alias.sh force
_e $? "$_S"


_S="[ DDU ] sourcing bashrc for DDT"
_pb "$_S"
source /home/pi/.bashrc
_e $? "$_S"



_pb "[ DDU ] OK, done"

