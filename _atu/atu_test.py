#!/usr/bin/env python3



from _atu_cmd import build_ssh_including_command
from atu_inv_all import ping_all



if __name__ == '__main__':
    s = ping_all()
    c = 'cat /home/pi/li/ddh/.ddh_version'
    timeout = 1
    build_ssh_including_command('test', c, timeout, str_of_hosts=s)

