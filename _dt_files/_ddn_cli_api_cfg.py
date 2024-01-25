#!/usr/bin/env python3


import sys
import requests
from _ddn_cli_api import (p,
                          get_interface_mac_address,
                          get_filename_from_content_disposition_header)


# VPN address of remote server
DDN_API_CFG_PORT = 9001
DDN_API_IP = '10.5.0.1'


# debug
g_debug = 0


def _main_cli_api_cfg(api_pw):
    if not api_pw:
        p('error: missing API pw parameter')
        return
    mac = get_interface_mac_address("eth0")
    if not mac:
        p('error: no interface eth0')
        return

    # useful when testing
    api_ip = DDN_API_IP if not g_debug else "0.0.0.0"

    # build and send API request to CFG endpoint
    u = f'http://{api_ip}:{DDN_API_CFG_PORT}/cfg/{mac}?pw={api_pw}'
    try:
        rsp = requests.get(u, timeout=5)
        rsp.raise_for_status()
    except (Exception, ) as ex:
        p(f'error: client exception -> {ex}')
        p(f'check mac is authorized and has remote config file associated')
        return

    # analyze API answer
    if rsp and rsp.status_code == 200:
        h = rsp.headers.get('content-disposition')
        fn = get_filename_from_content_disposition_header(h)
        if rsp.content == b'null':
            # p.e: bad mac or wrong password
            p('error: got API answer, but no file')
            p(f'check mac is authorized and has remote config file associated')
            return
        path_dl_config_file = f'/tmp/{fn}'
        with open(path_dl_config_file, 'wb') as f:
            f.write(rsp.content)
        p(f'file downloaded to {path_dl_config_file}')
    else:
        p(f'error: API server seems down')


def main():
    try:
        # password from command line
        _main_cli_api_cfg(sys.argv[1])
        # do not execute anything else
        return
    except (Exception, ):
        pass

    global g_debug
    g_debug = 1
    p("we must be debugging")
    _main_cli_api_cfg("pass_when_debug")


if __name__ == '__main__':
    # $ ./_ddn_cli_api_cfg.py <remote_api_pw> (vpn_api_pw_default)
    main()
