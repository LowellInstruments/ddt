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


def main():

    # wi-fi can go internet and we are already using it
    wlan_has_via = _sh('timeout 2 ping -c 1 -I wlan0 www.google.com')
    if wlan_has_via and _sh('ip route get 8.8.8.8 | grep wlan0'):
        _p('wi-fi')
        time.sleep(60)
        return

    # wi-fi cannot go internet, ensure we are really using it
    _sh('/usr/sbin/ifmetric ppp0 400')
    _p('ensuring we are trying wi-fi')
    time.sleep(2)

    # wi-fi, try again
    wlan_has_via = _sh('timeout 2 ping -c 1 -I wlan0 www.google.com')
    if wlan_has_via and _sh('ip route get 8.8.8.8 | grep wlan0'):
        _p('* wi-fi *')
        time.sleep(60)
        return

    # wi-fi does DEFINITELY NOT work, ensure we are trying cell
    rv = _sh('/usr/sbin/ifmetric ppp0 0')
    if not rv:
        _p('error ifmetric ppp0')
    time.sleep(2)

    # check cell can go to internet
    ppp_has_via = _sh('timeout 2 ping -c 1 -I ppp0 www.google.com')
    if ppp_has_via and _sh('ip route get 8.8.8.8 | grep ppp0'):
        _p('cell')
        # longer
        time.sleep(300)
        return

    _p('-')


if __name__ == '__main__':
    while 1:
        main()
