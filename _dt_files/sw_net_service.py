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


def main() -> int:

    wlan_via = _sh('timeout 2 ping -c 1 -I wlan0 www.google.com')
    wlan_used = _sh('ip route get 8.8.8.8 | grep wlan0')

    if wlan_via and wlan_used:
        _p('wi-fi')
        return 60

    if wlan_via and not wlan_used:
        # ensure we are using wi-fi interface as default
        _sh('/usr/sbin/ifmetric ppp0 400')
        _sh('/usr/sbin/ifmetric wlan0 0')
        time.sleep(2)
        wlan_used = _sh('ip route get 8.8.8.8 | grep wlan0')
        if wlan_used:
            _p('* wi-fi *')
            return 60

    # ensure we are using cell interface as default
    cell_via = _sh('timeout 2 ping -c 1 -I ppp0 www.google.com')
    _sh('/usr/sbin/ifmetric wlan0 400')
    _sh('/usr/sbin/ifmetric ppp0 0')
    time.sleep(2)
    cell_used = _sh('ip route get 8.8.8.8 | grep ppp0')
    if cell_via and cell_used:
        _p('cell')
        return 300

    # should never reach here
    _p('none')
    return 60


if __name__ == '__main__':
    while 1:
        rv_secs = main()
        time.sleep(rv_secs)
