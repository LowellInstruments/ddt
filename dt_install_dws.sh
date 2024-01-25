#!/usr/bin/env bash


F_LI=/home/pi/li


function install_dws {
    source dt_utils.sh
    _pb "INSTALL DWS, copy paste"
     cd $F_LI || (_pe "error: bad working directory"; exit 1)


    echo "cd /home/pi/Downloads;"
    echo "wget https://www.dwservice.net/download/dwagent.sh;"
    echo "chmod +x /home/pi/Downloads/dwagent.sh;"
    echo "sudo /home/pi/Downloads/dwagent.sh;"
    _py  "use 7-digit code created in your DWS account to add this host"

}
