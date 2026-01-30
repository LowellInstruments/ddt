#!/usr/bin/bash

# ------------------------------------------------------
# MNT: checks /home/pi/li on 3rd partition is mountable
# ------------------------------------------------------

F_VE=/home/pi/venv_gor


(source $F_VE/bin/activate &&  \
cd /home/pi && \
"$F_VE"/bin/python3 main_mnt.py) || \
echo "error: cannot run main_mnt.py"


# proof it ran
touch /home/pi/.ran_run_mnt.sh
