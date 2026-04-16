#!/usr/bin/env python3



import os
import subprocess as sp
import threading
import time
import queue
import platform
import sys



q = queue.Queue()
DDH_SSH_PASSWORD = os.getenv('DDH_SSH_PASSWORD')
if not DDH_SSH_PASSWORD:
    print('error, no variable DDH_SSH_PASSWORD')
    sys.exit(1)




def _ssh_prefix(
        timeout: int,
        ip_addr: str
):

    # build the whole ssh command prefix
    d_plat = {
        'Darwin': f'gtimeout {timeout} ',
        'Linux': f'timeout {timeout} '
    }
    cmd = d_plat[platform.system()]

    # 2 mechanisms of SSH authentication for our DDH
    cmd += f"sshpass -p '{DDH_SSH_PASSWORD}' "
    cmd += f'ssh -i $HOME/Downloads/id_key pi@{ip_addr} '
    cmd += '-o StrictHostKeyChecking=accept-new '
    return cmd




def atu_cmd(
        cmd: str,
        str_ls_ip_addr,
        timeout_cmd: int = 1
) -> dict:

    # declare function to parallelize run SSH command in remote part
    def _fxn_th(ip_addr_th):
        till_th = time.time() + (timeout_cmd - .1)
        while time.time() < till_th:
            try:
                cmd_ssh = _ssh_prefix(timeout=timeout_cmd, ip_addr=ip_addr_th)
                cmd_ssh = cmd_ssh + f'"{cmd}"'
                # debug
                # print(cmd_ssh)
                rv = sp.run(cmd_ssh, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
                s = rv.stdout.decode()
                # this is SSH return code
                if rv.returncode == 0:
                    d_ans_one = dict()
                    d_ans_one[ip_addr_th] = s
                    q.put(d_ans_one)
                break
            except (Exception, ):
                pass


    # main loop
    d_ans = dict()
    assert type(str_ls_ip_addr) is str
    ls_ip_addr = str_ls_ip_addr.split(' ')
    for ip_addr in ls_ip_addr:
        th = threading.Thread(target=_fxn_th, args=(ip_addr,))
        th.start()


    # recover the command answers
    till = time.time() + 1
    while time.time() < till:
        try:
            d = q.get(timeout=.1)
            d_ans.update(d)
        except queue.Empty:
            pass


    # dictionary
    return d_ans
