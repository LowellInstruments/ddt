#!/usr/bin/env python3



import os
import time
import subprocess as sp
import socket
import fcntl
import struct



prev_s = ''
PATH_INFO_FILE = '/home/pi/Desktop/INFO.md'


def get_ip_address(if_name):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', if_name[:15])
    )[20:24])




def main():


    # spacer
    print('\n\n\n\n')

    # get IP of interface wlan on Rpi
    ip_wlan = 'N/A'
    try:
        ip_wlan = get_ip_address(b'wlan0')
    except (Exception, ) as e:
        print(f'SER: error getting WLAN IP address -> {e}')


    # get IP of interface VPN on Rpi
    ip_vpn = 'N/A'
    try:
        ip_vpn = get_ip_address(b'wg0')
    except (Exception,) as e:
        print(f'SER: error getting VPN IP address -> {e}')


    # get boat name
    ship_name = 'N/A'
    c = 'cat /home/pi/li/ddh/settings/config.toml | grep ship_name'
    try:
        rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
        if rv.returncode == 0:
            ship_name = rv.stdout.decode()
    except (Exception,) as e:
        print(f'SER: error getting ship name -> {e}')


    # get boat serial number
    box_sn = 'N/A'
    c = 'cat /home/pi/li/ddh/settings/config.toml | grep cred_ddh_serial_number'
    try:
        rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
        if rv.returncode == 0:
            box_sn = rv.stdout.decode().replace('\n', '')
    except (Exception,) as e:
        print(f'SER: error getting box SN -> {e}')


    # create the desktop file
    try:
        s = f'{box_sn}\n\nwlan_addr = {ip_wlan}\n\n vpn_addr = {ip_vpn}\n\n'
        s += f'{ship_name}\n\n'
        global prev_s
        if not os.path.exists(PATH_INFO_FILE) or (s != prev_s):
            with open(PATH_INFO_FILE, 'w') as f:
                f.write(s)
        prev_s = s
    except (Exception,) as e:
        print(f'SER: error creating info desktop file -> {e}')



if __name__ == '__main__':
    if os.path.exists(PATH_INFO_FILE):
        os.unlink(PATH_INFO_FILE)
    while 1:
        main()
        time.sleep(10)
