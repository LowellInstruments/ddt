#!/usr/bin/env python3


import time
import subprocess as sp
import sys
import socket


# make this code independent of mat library
DDH_GUI_UDP_PORT = 12349
STATE_DDS_NOTIFY_NET_VIA = 'net_via'


_sk = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)


def _u(s):
    _sk.sendto(str(s).encode(), ('127.0.0.1', DDH_GUI_UDP_PORT))


def _p(s):
    print('[ NET ] LI: {}'.format(s))
    # o/wise output not shown in journalctl
    sys.stdout.flush()


def _sh(s: str) -> bool:
    rv = sp.run(s, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    return rv.returncode == 0


def main():

    # wi-fi can go internet and we already use it
    wlan_has_via = _sh('timeout 2 ping -c 1 -I wlan0 www.google.com')
    if wlan_has_via and _sh('ip route get 8.8.8.8 | grep wlan0'):
        _p('wi-fi')
        _u('{}/{}'.format(STATE_DDS_NOTIFY_NET_VIA, 'wifi'))
        time.sleep(60)
        return

    # wi-fi cannot go internet, are we really using it
    if not _sh('/usr/sbin/ifmetric ppp0 400'):
        _p('ifmetric error ppp0 400')
        time.sleep(2)

    # wi-fi, try again
    wlan_has_via = _sh('timeout 2 ping -c 1 -I wlan0 www.google.com')
    if wlan_has_via and _sh('ip route get 8.8.8.8 | grep wlan0'):
        _p('* wi-fi *')
        _u('{}/{}'.format(STATE_DDS_NOTIFY_NET_VIA, 'wifi'))
        time.sleep(60)
        return

    # wi-fi does NOT work, make sure we try cell
    if not _sh('/usr/sbin/ifmetric ppp0 0'):
        _p('ifmetric error ppp0 0')
        time.sleep(2)

    # check cell can go to internet
    ppp_has_via = _sh('timeout 2 ping -c 1 -I ppp0 www.google.com')
    if ppp_has_via and _sh('ip route get 8.8.8.8 | grep ppp0'):
        _p('cell')
        _u('{}/{}'.format(STATE_DDS_NOTIFY_NET_VIA, 'cell'))
        # longer
        time.sleep(300)
        return

    _p('-')
    _u('{}/{}'.format(STATE_DDS_NOTIFY_NET_VIA, 'none'))


if __name__ == '__main__':
    # see all services -> systemctl list-units --type=service
    while 1:
        main()