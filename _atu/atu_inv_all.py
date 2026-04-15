#!/usr/bin/env python3



import subprocess as sp
import threading
import time
import queue



q = queue.Queue()
mask_vpn = '10.5.0.'
mask_local = '192.168.0.'
ls_ip_vpn = [f'{mask_vpn}{i}' for i in range(10, 250, 1)]
ls_ip_local = [f'{mask_local}{i}' for i in range(10, 250, 1)]



def _th_cmd(cmd, i, timeout):
    till = time.time() + (timeout - .1)
    while time.time() < till:
        try:
            rv = sp.run(cmd, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
            if rv.returncode == 0:
                q.put(f'{i}')
            break
        except (Exception, ):
            pass


def ping_all():

    timeout = 1
    for i in ls_ip_vpn:
        c = f'ping -c 1 {i}'
        th = threading.Thread(target=_th_cmd, args=(c, i, timeout))
        th.start()

    for i in ls_ip_local:
        c = f'ping -c 1 {i}'
        th = threading.Thread(target=_th_cmd, args=(c, i, timeout))
        th.start()

    # recover the answers
    till = time.time() + timeout
    ls = []
    while time.time() < till:
        try:
            i = q.get(timeout=.1)
            ls.append(i)
        except queue.Empty:
            pass


    # use space as answer separator
    s = ' '.join(ls) or ''
    print(s)
    print(f'({len(ls)} all)')
    return s



if __name__ == '__main__':
    ping_all()
