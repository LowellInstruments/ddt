#!/usr/bin/env python3



import sys
import os
import subprocess as sp
import platform


DDH_SSH_PASSWORD = os.getenv('DDH_SSH_PASSWORD')



def build_ssh_without_command(timeout, ip):
    assert DDH_SSH_PASSWORD is not None
    if platform.system() == 'Darwin':
        c = f'gtimeout {timeout} '
    else:
        c = f'timeout {timeout} '

    # 2 mechanisms of authenticating
    c += f"sshpass -p '{DDH_SSH_PASSWORD}' "
    c += f'ssh -i $HOME/Downloads/id_key pi@{ip} '
    c += '-o StrictHostKeyChecking=accept-new '
    return c



def build_ssh_including_command(
        short_cmd: str,
        long_cmd: str,
        timeout: int,
        str_of_hosts: str
):
    os.system('clear')
    print(f'aut_{short_cmd} start', flush=True)
    ls_argv = sys.argv
    ls_hosts = str_of_hosts.split(' ')
    ls = ls_argv if len(ls_argv) > 1 else ls_hosts

    for i in ls:
        print(f'\tdoing {short_cmd} @{i}')
        c = build_ssh_without_command(timeout, i) + f'"{long_cmd}"'
        rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
        a = rv.stdout.decode()
        print(f'\t{a}', flush=True)
    print(f'aut_{short_cmd} end', flush=True)

