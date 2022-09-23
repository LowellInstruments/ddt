#!/usr/bin/env bash


# grab variables from file
. ./dt_variables.sh || (echo 'dt_vars fail'; exit 1)
J4H="$F_LI"/juice4halt


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install bluez ----\n'

# ########################
# todo> do this
# ########################

wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.61.tar.xz