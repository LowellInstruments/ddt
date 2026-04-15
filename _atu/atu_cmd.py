#!/usr/bin/env python3



import sys
import os
from atu_utils import utils_get_ssh
import subprocess as sp



def cmd(
        short: str,
        long: str,
        timeout: int
):
    os.system('clear')
    print(f'aut_{short} start', flush=True)
    ls = sys.argv
    if len(ls) > 1:
        ls = ls[1:]
        for i in ls:
            print(f'\tdoing {i}')
            c = utils_get_ssh(timeout, i) + f'"{long}"'
            rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
            a = rv.stdout.decode()
            print(f'\t{a}', flush=True)
    print(f'aut_{short} end', flush=True)

