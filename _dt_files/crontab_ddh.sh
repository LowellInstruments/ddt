#!/usr/bin/env bash


# grab, aka 'source', variables from file
. ./dt_variables.sh || (echo 'dt_vars fail'; exit 1)
clear


# once every boot
if [ ! -f /tmp/flag_ddh_update ]; then
    echo '[ DDH ] trying update once per day is OK'
    ./dt_install_python_all_mat_ddh.sh
    touch /tmp/flag_ddh_update
else
    echo '[ DDH ] flag found, NOT performing update'
fi


printf "[ DDH ] running crontab_ddh.sh\n"
/home/pi/li/ddh/run_ddh.sh&
/home/pi/li/ddh/run_dds.sh&
