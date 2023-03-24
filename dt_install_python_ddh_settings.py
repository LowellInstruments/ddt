#!/usr/bin/env python3


import os
import sys
import subprocess as sp
import requests


def _is_rpi():
    c = 'cat /proc/cpuinfo | grep Raspberry'
    rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    return rv.returncode == 0


def _p(s):
    print('[ DDH ] REQ settings | {}'.format(s))


def ddh_req_settings(ip, port, fol, filename):

    # parameter check and banner
    assert filename in ('run_dds.sh', 'ddh.json')
    _p('\n\n')
    _p('current path is {}'.format(os.getcwd()))
    _p('getting file {} from vessel SN {}'.format(fol, filename))
    prs = {'fol': fol, 'filename': filename}

    # -------------------------
    # send HTTP request to DDN
    # -------------------------
    url = 'http://{}:{}/ddh_conf'.format(ip, port)
    rsp = requests.get(url, params=prs)
    if rsp.status_code != 200:
        s = 'error: cannot get file {} from vessel SN {}'
        _p(s.format(filename, fol, rsp.status_code))
        return 1

    # save content from HTTP answer
    with open(filename, 'w') as f:
        f.write(rsp.content.decode())
        _p('OK: file {} downloaded'.format(filename))

    # for testing
    if not _is_rpi():
        _p('OK: file {} downloaded but no RPI, quit\n'.format(filename))
        return 0

    # install files
    path = {
        'run_dds.sh': '/home/pi/li/ddh',
        'ddh.json': '/home/pi/li/ddh/settings',
    }
    c = 'cp run_dds.sh {}'.format(path)
    rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    if rv.returncode:
        _p('error: installing downloaded file {}\n'.format(filename))
        return 1

    # show a nice message
    s = 'OK: file {} installed in {}\n'
    _p(s.format(filename, path[filename]))


if __name__ == '__main__':
    # $ python3 dt_install_python_ddh_settings.py <ip> <port> 1234567 ddh.json
    ddh_req_settings(*sys.argv[1:])
    # or test as typical python function
    # ddh_req_settings('<ip>', port, '1234567', 'ddh.json')
