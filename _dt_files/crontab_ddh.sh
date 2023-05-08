#!/usr/bin/env bash


# --------------------------------
# update and run DDH from crontab
# --------------------------------

printf "[ DDH ] running crontab_ddh.sh\n"
ENABLE_UPDATE=0
RV=0


# this runs only once per boot
if [ ! -f /tmp/ddh_got_update_file.flag ]; then

    # =================================
    # will NOT run if flag above is 0
    # =================================

    if [ $ENABLE_UPDATE -eq 1 ]; then
      printf '[ DDH ] trying update once per day is OK \n'
      ../dt_update_all_ddh.sh
      RV=$?
      printf '[ DDH ] creating file flag updating \n'
      touch /tmp/ddh_got_update_file.flag

    else
      printf '[ DDH ] ENABLE_UPDATE is off, NOT updating at this boot\n'
    fi

else
    printf '[ DDH ] update flag present, NOT updating at this boot\n'
fi


# ------------------------------------------------------------------
# this tries to run both, if one already running, it does not harm
# ------------------------------------------------------------------
if [ $RV -ne 0 ]; then
    printf '[ DDH ] ERROR updating DDH\n'
fi


/home/pi/li/ddh/run_ddh.sh&
/home/pi/li/ddh/run_dds.sh&
