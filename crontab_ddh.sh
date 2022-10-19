#!/usr/bin/env bash


# dt_update_x is called at rc.local


# grab, aka 'source', variables from file
. ./dt_variables.sh || (echo 'dt_vars fail'; exit 1)


printf "running crontab_ddh.sh\n"
"$F_DA"/run_ddh.sh&
"$F_DA"/run_dds.sh&
