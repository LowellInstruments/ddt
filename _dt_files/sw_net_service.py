#!/usr/bin/env python3


import time
import subprocess as sp
import sys



IP = '8.8.8.8'
URL = 'www.google.com'
TIMEOUT_NO_DNS = 5
TIMEOUT_W_DNS = 10
CMD_IFMETRIC = '/usr/sbin/ifmetric'
g_ts = 0


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



def _z(s):
    fixed_sleeping_while_developing = 0
    if fixed_sleeping_while_developing:
        return 5

    if s == 'wifi':
        return 30
    if s == 'cell':
        return 120
    # none
    return 10




def main() -> int:

    global g_ts
    wlan_via = _sh(f'ping -w {TIMEOUT_NO_DNS} -I wlan0 {IP}')
    wlan_used = _sh(f'ip route get {IP} | grep wlan0')

    if time.perf_counter() - g_ts > 600:
        g_ts = time.perf_counter
        dns_works_wifi = _sh(f'ping -w {TIMEOUT_W_DNS} -I wlan0 {URL}')
        dns_works_cell = _sh(f'ping -w {TIMEOUT_W_DNS} -I ppp0 {URL}')
        if not dns_works_wifi and not dns_works_cell:
            _p('* DNS error *')

    if wlan_via and wlan_used:
        _p('wifi')
        return _z('wifi')

    if wlan_via and not wlan_used:
        _sh(f'{CMD_IFMETRIC} ppp0 400')
        _sh(f'{CMD_IFMETRIC} wlan0 0')
        _p('* wifi *')
        return _z('wifi')

    cell_via = _sh(f'ping -w {TIMEOUT_NO_DNS} -I ppp0 {IP}')
    cell_used = _sh(f'ip route get {IP} | grep ppp0')

    if cell_via and cell_used:
        _p('cell')
        return _z('cell')

    # do NOT move this inside the condition
    _sh(f'{CMD_IFMETRIC} wlan0 400')
    _sh(f'{CMD_IFMETRIC} ppp0 0')
    if cell_via and not cell_used:
        _p('* cell *')
        return _z('cell')

    _p('none')
    return _z('none')


if __name__ == '__main__':
    while 1:
        rv_secs = main()
        time.sleep(rv_secs)
