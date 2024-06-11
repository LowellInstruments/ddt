#!/usr/bin/env bash
source dt_utils.sh



function backup_yellow {
    title dt_backup_yellow


    _pb "BACKUP DDH YELLOW VERSION"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "detecting old yellow boat DDH version"
    [ -f /home/pi/li/ddh/settings/ddh.json ]
    rv=$?
    if [ $rv -eq 0 ]; then
        _pb "creating old yellow boat DDH folder backup to ddh_yellow"
        mv "$FOL_DDH" "$FOL_LI"/ddh_yellow
    fi


    _pb "killing any currently running DDH software"
    killall main_ddh_controller
    killall main_ddh
    kilall main_dds_controller
    killall main_dds


    _pb "backup_yellow done, proceed to run ./dt_install_all.sh"
}


if [ "$1" == "force" ]; then backup_yellow; fi

