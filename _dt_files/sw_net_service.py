#!/usr/bin/env python3


import time
import subprocess as sp
import sys


IP = '8.8.8.8'


# ----------------------------------------
# last version of net service
# for sixfab ppp0 interfaces
# it does NOT feature UDP capabilities
# ----------------------------------------


def _p(s):
    print('[ NET ] LI: {}'.format(s))
    # o/wise output not shown in journalctl
    sys.stdout.flush()


def _sh(s: str) -> bool:
    rv = sp.run(s, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    return rv.returncode == 0


g_debug = False


def _z(s):
    if g_debug:
        return 10
    if s in 'wifi':
        return 60
    if s == 'cell':
        return 300
    # none
    return 60


def main() -> int:

    # best wi-fi case ever
    wlan_via = _sh('timeout 2 ping -c 1 -I wlan0 {}'.format(IP))
    wlan_used = _sh('ip route get {} | grep wlan0'.format(IP))
    if wlan_via and wlan_used:
        _p('wifi')
        return _z('wifi')

    # seems no wi-fi, but maybe it only needs some adjustment
    if wlan_via and not wlan_used:
        _sh('/usr/sbin/ifmetric ppp0 400')
        _sh('/usr/sbin/ifmetric wlan0 0')
        time.sleep(2)
        wlan_used = _sh('ip route get {} | grep wlan0'.format(IP))
        if wlan_used:
            _p('* wifi *')
            return _z('wifi')

    # no wi-fi, let's try cell
    cell_via = _sh('timeout 2 ping -c 1 -I ppp0 {}'.format(IP))
    cell_used = _sh('ip route get {} | grep ppp0'.format(IP))

    # debug
    if g_debug:
        _p('wlan_via = {}'.format(wlan_via))
        _p('wlan_used = {}'.format(wlan_used))
        _p('cell_via = {}'.format(cell_via))
        _p('cell_used = {}'.format(cell_used))

    # seems no cell, but maybe it only needs some adjustment
    if cell_via and not cell_used:
        _sh('/usr/sbin/ifmetric wlan0 400')
        _sh('/usr/sbin/ifmetric ppp0 0')

    # let's try cell again after adjustment
    cell_used = _sh('ip route get {} | grep ppp0'.format(IP))
    if cell_via and cell_used:
        _p('cell')
        return _z('cell')

    # no internet connection of any kind
    _p('none')
    return _z('none')


if __name__ == '__main__':
    while 1:
        rv_secs = main()
        time.sleep(rv_secs)
