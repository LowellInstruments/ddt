#!/usr/bin/env bash


# dt_update_x is called at rc.local


# grab variables from file
. ./dt_variables.sh || (echo 'dt_vars fail'; exit 1)


printf "crontab -> ddh_run.sh\n"


"$F_DA"/ddh_run.sh&
rv=$?
if [ $rv -ne 0 ]; then
    printf "crontab could not run DDH!"
    exit 1
fi

"$F_DA"/dds_run.sh&
rv=$?
if [ $rv -ne 0 ]; then
    printf "crontab could not run DDS!"
    exit 1
fi
