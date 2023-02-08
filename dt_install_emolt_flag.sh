#!/usr/bin/env bash


EMOLT_FILE_FLAG=/home/pi/li/.emolt_file_flag
USING_GPS_EXTERNAL='/home/pi/li/.using_gps_external_flag'


echo; echo;
read -rp "Continue (y/n)?" choice
case "$choice" in
    # create both files
    y|Y ) touch $EMOLT_FILE_FLAG; touch $USING_GPS_EXTERNAL;;
esac

