#!/usr/bin/env python3


import time
import subprocess as sp
import sys


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


g_sleep_debug = True

def _z(s):
    if g_sleep_debug:
        return 10
    if s in 'wifi':
        return 60
    if s == 'cell':
        return 300
    # none
    return 60


def main() -> int:

    # the best wifi case ever
    wlan_via = _sh('timeout 2 ping -c 1 -I wlan0 www.google.com')
    wlan_used = _sh('ip route get 8.8.8.8 | grep wlan0')
    if wlan_via and wlan_used:
        _p('wifi')
        return _z('wifi')

    # seems no wifi, but maybe wifi just needs some adjustment
    if wlan_via and not wlan_used:
        _sh('/usr/sbin/ifmetric ppp0 400')
        _sh('/usr/sbin/ifmetric wlan0 0')
        time.sleep(2)
        wlan_used = _sh('ip route get 8.8.8.8 | grep wlan0')
        if wlan_used:
            _p('* wifi *')
            return _z('wifi')

    # no wifi, try the best cell case ever
    cell_via = _sh('timeout 2 ping -c 1 -I ppp0 www.google.com')
    cell_used = _sh('ip route get 8.8.8.8 | grep ppp0')
    if cell_via and cell_used:
        _p('cell')
        return _z('cell')

    # seems no cell, but maybe cell just needs some adjustment
    if cell_via and not cell_used:
        _sh('/usr/sbin/ifmetric wlan0 400')
        _sh('/usr/sbin/ifmetric ppp0 0')
        time.sleep(2)
        cell_used = _sh('ip route get 8.8.8.8 | grep ppp0')
        if cell_used:
            _p('* cell *')
            return _z('cell')

    # no internet connection of any kind
    _p('none')
    return _z('none')


if __name__ == '__main__':
    while 1:
        rv_secs = main()
        time.sleep(rv_secs)
