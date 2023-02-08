#!/usr/bin/env bash


EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag
USING_GPS_EXTERNAL=/home/pi/li/.ddt_using_gps_external.flag


echo; echo;
read -rp "Set this DDH as emolt? (y/n) " choice
case "$choice" in
    # create both files
    y|Y ) touch $EMOLT_FILE_FLAG; touch $USING_GPS_EXTERNAL;;
esac
echo


