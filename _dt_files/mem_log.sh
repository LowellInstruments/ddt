#!/usr/bin/env bash

FO=usage_mem.log

while true; do
	top -bn 1 -o +%MEM | grep "load average" -A 9 | tee -a $FO
	echo | tee -a $FO
	sleep 5
done
