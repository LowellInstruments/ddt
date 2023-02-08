#!/usr/bin/env bash


# --------------------------------
# update and run DDH from crontab
# --------------------------------


# this will only run once per boot
if [ ! -f /tmp/ddh_got_update_file.flag ]; then
    # option 1
    # --------
    # echo '[ DDH ] trying update once per day is OK'
    # ./dt_install_python_all_mat_ddh.sh
    # touch /tmp/ddh_got_update_file.flag

    # option 2
    # --------
    echo '[ DDH ] will test this auto-update soon'
else
    echo '[ DDH ] flag already present, NOT performing update'
fi


# ------------------------------------------------------------------
# this tries to run both, if one already running, it does not harm
# ------------------------------------------------------------------
printf "[ DDH ] running crontab_ddh.sh\n"
/home/pi/li/ddh/run_ddh.sh&
/home/pi/li/ddh/run_dds.sh&
