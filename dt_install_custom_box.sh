#!/usr/bin/env bash


# --------------------------------------------------
# creates flags that other installers rely upon
# also affects global file upload behavior
# finer tweaking flags in file ddh/settings/ctx.py
# --------------------------------------------------


EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag
GROUPED_S3_FILE_FLAG=/home/pi/li/.ddt_this_box_has_grouped_s3_uplink.flag



# remove everything before starting
rm $EMOLT_FILE_FLAG 2> /dev/null
rm $GROUPED_S3_FILE_FLAG 2> /dev/null


echo; echo;
read -rp "Set this DDH as emolt? (y/n) " choice
# affects dt_install_linux.sh /rc.local juice4halt, net switching service...
case "$choice" in
    y|Y ) touch $EMOLT_FILE_FLAG; printf 'set emolt OK';;
esac
echo


echo; echo;
read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
# how DDH groups files before S3 upload
case "$choice" in
    y|Y ) touch $GROUPED_S3_FILE_FLAG; printf 'set grouped S3 OK';;
esac
echo
