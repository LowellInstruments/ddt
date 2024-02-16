#!/usr/bin/bash



source /home/pi/li/ddh/scripts/utils.sh
clear


_S="[ POP ] ddt | updating"
_pb "$_S"
cd "$FOL_DDT" && git reset --hard && git pull
_e $? "$_S"


_S="[ POP ] ddt | new aliases"
_pb "$_S"
cd "$FOL_DDT" && ./dt_install_alias.sh force
_e $? "$_S"



_pb "[ POP ] ddt | done OK!"

