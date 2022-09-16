#!/usr/bin/env bash


# remember to add to /etc/sudoers
# kaz ALL=(ALL) NOPASSWD: /home/kaz/PycharmProjects/ddh_tools/set_linux_ble_conn_parameters.sh
# pi ALL=(ALL) NOPASSWD: /home/pi/li/ddh/ddh_tools/set_linux_ble_conn_parameters.sh



if [ $# -ne 1 ]; then
    echo 'bad number of parameters for this script'
    exit 1
fi


if [ "$1" != "slow" -a "$1" != 'fast' ]; then
    echo "$0: argument must be 'slow' or 'fast'"
    exit 2
fi

rv="$(cat /sys/kernel/debug/bluetooth/hci0/conn_min_interval)"
printf "current BLE conn_min_interval is %d", "$rv"
rv="$(cat /sys/kernel/debug/bluetooth/hci0/conn_max_interval)"
var=$(printf "current BLE conn_max_interval is %d", "$rv")
echo "$var"


# set desired, one ordering will work, ignore InvalidArgument error
if [ "$1" == "slow" ]; then
    echo 48 > /sys/kernel/debug/bluetooth/hci0/conn_min_interval
    echo 80 > /sys/kernel/debug/bluetooth/hci0/conn_max_interval
    echo 80 > /sys/kernel/debug/bluetooth/hci0/conn_max_interval
    echo 48 > /sys/kernel/debug/bluetooth/hci0/conn_min_interval
fi
if [ "$1" == "fast" ]; then
    echo 24 > /sys/kernel/debug/bluetooth/hci0/conn_min_interval
    echo 40 > /sys/kernel/debug/bluetooth/hci0/conn_max_interval
    echo 40 > /sys/kernel/debug/bluetooth/hci0/conn_max_interval
    echo 24 > /sys/kernel/debug/bluetooth/hci0/conn_min_interval
fi



rv="$(cat /sys/kernel/debug/bluetooth/hci0/conn_min_interval)"
echo "new BLE conn_min_interval is $rv"
rv="$(cat /sys/kernel/debug/bluetooth/hci0/conn_max_interval)"
echo "new BLE conn_min_interval is $rv"


