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
    print(f'SW_NET - {s}')
    # o/wise output not shown in journalctl
    #   $ journalctl -u unit_switch_net.service
    sys.stdout.flush()


def _sh(s: str) -> bool:
    rv = sp.run(s, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    return rv.returncode == 0


g_debug = 0


def _z(s):
    # helps developing
    if g_debug:
        return 10

    if s == 'wifi':
        return 30
    if s == 'cell':
        return 30
    # none
    return 10


def main() -> int:

    c_im = '/usr/sbin/ifmetric'
    wlan_via = _sh(f'timeout 1 ping -c 1 -I wlan0 {IP}')
    wlan_used = _sh(f'ip route get {IP} | grep wlan0')

    if wlan_via and wlan_used:
        _p('wifi')
        return _z('wifi')

    if wlan_via and not wlan_used:
        _sh(f'{c_im} ppp0 400')
        _sh(f'{c_im} wlan0 0')
        _p('* wifi *')
        return _z('wifi')

    cell_via = _sh(f'timeout 1 ping -c 1 -I ppp0 {IP}')
    cell_used = _sh(f'ip route get {IP} | grep ppp0')

    if cell_via and cell_used:
        _p('cell')
        return _z('cell')

    if cell_via and not cell_used:
        _sh(f'{c_im} wlan0 400')
        _sh(f'{c_im} ppp0 0')
        _p('* cell *')
        return _z('cell')

    _p('none')
    return _z('none')


if __name__ == '__main__':
    while 1:
        rv_secs = main()
        time.sleep(rv_secs)
