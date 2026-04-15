#!/usr/bin/env python3



from _atu_cmd import cmd
from atu_inv_all import ping_all



if __name__ == '__main__':
    timeout = 1
    ls = ping_all()
    for i in ls:
        c = 'cat /home/pi/li/ddh/.ddh_version'
        cmd('test', c, timeout, list_of_hosts=ls)

