#!/usr/bin/env bash


# grab variables from file
. ./_dt_files/dt_variables.sh || (echo 'dt_vars fail'; exit 1)


# abort upon any error
echo && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install / Update DDH ----\n'


# clone DDH from git -> /tmp
printf 'I > clone from github\n'
rm -rf "$F_TA" || true
git clone https://github.com/lowellinstruments/ddx.git "$F_TA"



# backup existing DDH configuration -> /tmp
printf 'I > backup\n'
if [ -d "$F_DA"/dl_files ]; then cp -r "$F_DA"/dl_files "$F_TA"; fi
if [ -t "$F_DA"/run_dds.sh ]; then cp "$F_DA"/run_dds "$F_TA"; fi
if [ -t "$F_DA"/settings/ddh.json ]; then cp "$F_DA"/settings/ddh.json "$F_TA"/settings; fi
cp "$F_DA"/settings/_macs_to_sn.yml "$F_TA"/settings || true



# we reached here, we are doing well
printf 'I > install\n'
rm -rf "$F_DA"
mv "$F_TA" "$F_DA"
$VPIP install -r "$F_DA"/requirements.txt


printf 'I > ensuring resolv.conf \n'
sudo chattr -i /etc/resolv.conf
sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf


echo; echo 'I > DDH finished'
