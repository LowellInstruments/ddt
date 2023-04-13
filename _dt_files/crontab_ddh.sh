#!/usr/bin/env bash


# --------------------------------
# update and run DDH from crontab
# --------------------------------


ENABLE_UPDATE=0


# this runs only once per boot
if [ ! -f /tmp/ddh_got_update_file.flag ]; then

    if [ $ENABLE_UPDATE -eq 1 ]; then
      printf '[ DDH ] trying update once per day is OK'
      ../dt_install_python_all_mat_ddh.sh
      rv=$?
      if [ $rv -ne 0 ]; then
          printf '[ DDH ] error -> ./dt_install_python_all_mat_ddh.sh did not go OK'
          exit 1
      fi
      printf '[ DDH ] creating file flag updating'
      touch /tmp/ddh_got_update_file.flag

    else
      printf '[ DDH ] will test this auto-update soon'
    fi

else
    printf '[ DDH ] update flag already present, NOT performing update'
fi


# ------------------------------------------------------------------
# this tries to run both, if one already running, it does not harm
# ------------------------------------------------------------------
printf "[ DDH ] running crontab_ddh.sh\n"
/home/pi/li/ddh/run_ddh.sh&
/home/pi/li/ddh/run_dds.sh&
