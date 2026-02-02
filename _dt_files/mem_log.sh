#!/usr/bin/env bash

FO=/home/pi/li/ddt/_dt_files/usage_mem.log

#while true; do
#       top -bn 1 -o +%MEM | grep "load average" -A 9 | tee -a $FO
#       echo | tee -a $FO
#       sleep 5
#done


# when run via crontab, only once
# */5 * * * * pi /home/pi/li/ddt/_dt_files/mem_log.sh
top -bn 1 -o +%MEM | grep "load average" -A 20 | tee -a $FO
echo | tee -a $FO
