#!/usr/bin/env bash


# once every boot
if [ ! -f /tmp/flag_ddh_update_for_crontab ]; then
    # calls script ALL == MAT + DDH
    echo '[ DDH ] trying update once per day is OK'
    ./dt_install_python_all_mat_ddh.sh
    touch /tmp/flag_ddh_update_for_crontab
else
    echo '[ DDH ] flag found, NOT performing update'
fi


printf "[ DDH ] running crontab_ddh.sh\n"
/home/pi/li/ddh/run_ddh.sh&
/home/pi/li/ddh/run_dds.sh&
