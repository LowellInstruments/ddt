#!/usr/bin/env python3



import subprocess as sp
import threading
import time
import queue
from atu_utils import utils_get_ssh



q = queue.Queue()
TIMEOUT_CMD_BEACON_PING = 1
mask_vpn = '10.5.0.'
mask_local = '192.168.0.'
ls_ip_vpn = [f'{mask_vpn}{i}' for i in range(10, 250, 1)]
ls_ip_local = [f'{mask_local}{i}' for i in range(10, 250, 1)]



def th_cmd(cmd, i, timeout):
    till = time.time() + (timeout - .1)
    while time.time() < till:
        try:
            rv = sp.run(cmd, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
            a = rv.stdout.decode().replace('\n', '')
            if a == '1':
                q.put(f'{i}')
            break
        except (Exception, ):
            pass



def ping_beacon():
    ts = time.time()
    timeout = TIMEOUT_CMD_BEACON_PING
    for i in ls_ip_vpn:
        c = utils_get_ssh(timeout, i)
        c += '"redis-cli get ddh:gui:gui_beacon_flag"'
        th = threading.Thread(target=th_cmd, args=(c, i, timeout))
        th.start()

    for i in ls_ip_local:
        c = utils_get_ssh(timeout, i)
        c += '"redis-cli get ddh:gui:gui_beacon_flag"'
        th = threading.Thread(target=th_cmd, args=(c,i, timeout))
        th.start()

    # recover the answers
    till = time.time() + TIMEOUT_CMD_BEACON_PING
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
    return s



if __name__ == '__main__':
    ping_beacon()
