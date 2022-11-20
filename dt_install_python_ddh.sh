#!/usr/bin/env bash


# grab variables from file
. ./_dt_files/dt_variables.sh || (echo 'dt_vars fail'; exit 1)


printf '\n[ DDH ] --- running install_ddh.sh ---\n\n'



# nice environment
printf '[ DDH ] ensuring good DNS entries in resolv.conf \n\n'
sudo chattr -i /etc/resolv.conf
sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf


# abort upon any error
echo && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


# clone DDH from git -> /tmp
printf "\n[ DDH ] clone app from github to %s \n\n" "$F_TA"
rm -rf "$F_TA" || true
git clone https://github.com/lowellinstruments/ddx.git "$F_TA"



# backup existing DDH configuration -> /tmp
printf "\n[ DDH ] copying any current DDH configuration to %s \n\n" "$F_TA"
if [ -d "$F_DA"/dl_files ]; then cp -r "$F_DA"/dl_files "$F_TA"; fi
if [ -d "$F_DA"/logs ]; then cp -r "$F_DA"/logs "$F_TA"; fi
if [ -f "$F_DA"/run_dds.sh ]; then cp "$F_DA"/run_dds.sh "$F_TA"; fi
if [ -f "$F_DA"/settings/ddh.json ]; then cp "$F_DA"/settings/ddh.json "$F_TA"/settings; fi
cp "$F_DA"/settings/_macs_to_sn.yml "$F_TA"/settings || true



# we reached here, we are doing well
printf "\n[ DDH ] removing current DDH, copying %s as current \n\n" "$F_TA"
rm -rf "$F_DA"
mv "$F_TA" "$F_DA"
$VPIP install -r "$F_DA"/requirements.txt


printf '\n[ DDH ] installed app OK!\n\n'
