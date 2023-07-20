#!/usr/bin/env bash


EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag
USING_GPS_EXTERNAL=/home/pi/li/.ddt_using_gps_external.flag
GROUPED_S3_FILE_FLAG=/home/pi/li/.ddt_this_box_has_grouped_s3_uplink.flag


# remove everything before starting
rm $EMOLT_FILE_FLAG 2> /dev/null
rm $USING_GPS_EXTERNAL 2> /dev/null
rm $GROUPED_S3_FILE_FLAG 2> /dev/null


echo; echo;
read -rp "Set this DDH as emolt? (y/n) " choice
case "$choice" in
    # create both files
    y|Y ) touch $EMOLT_FILE_FLAG; touch $USING_GPS_EXTERNAL; printf 'set emolt OK';;
esac
echo


echo; echo;
read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
case "$choice" in
    # create both files
    y|Y ) touch $GROUPED_S3_FILE_FLAG; printf 'set grouped S3 OK';;
esac
echo



