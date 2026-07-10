
cd /etc/NetworkManager/system-connections/

# step 1 - create a file.nmconnection, set priority in [connection] section
autoconnect-priority=100
chmod 0600 file.nmconnection

# step 2 - import newly created files
nmcli conn reload
nmcli -f name,autoconnect,autoconnect-priority connection show
sudo systemctl restart NetworkManager

reboot




