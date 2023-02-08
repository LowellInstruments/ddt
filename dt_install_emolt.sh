#!/usr/bin/env bash


EMOLT_FLAG=/home/pi/li/.emolt_flag


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


echo;
read -rp "Continue (y/n)?" choice
case "$choice" in
  y|Y ) touch $EMOLT_FLAG;;
esac

done