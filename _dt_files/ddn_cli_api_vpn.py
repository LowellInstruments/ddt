#!/usr/bin/env python3


import json
import sys
import requests
from pathlib import Path
import re
from getmac import get_mac_address


def p(s):
    print(f'[ DDN ] cli | {s}')


def get_interface_mac_address(i):
    mac = get_mac_address(interface=i)
    if not mac:
        return
    mac = mac.replace(':', '_')
    mac = mac.replace('-', '_')
    return mac


def get_filename_from_content_disposition_header(cd):
    # src: codementor, downloading-files-from-urls-in-python-77q3bs0un
    if not cd:
        return None
    s = re.findall('filename=(.+)', cd)
    if len(s) == 0:
        return None
    return s[0].replace('"', '')


# VPN address of remote server
DDN_API_VPN_PORT = 9000
DDN_API_IP = 'ddn.lowellinstruments.com'


# debug
g_debug = 0


def _main_cli_api_vpn(api_pw):
    if not api_pw:
        p('error: missing API pw parameter')
        return
    mac = get_interface_mac_address("eth0")
    if not mac:
        p('error: no interface eth0')
        return

    # useful when testing
    api_ip = DDN_API_IP if not g_debug else "0.0.0.0"

    # build and send API request to VPN endpoint
    url = f'http://{api_ip}:{DDN_API_VPN_PORT}/vpn_ip?mac={mac}&pw={api_pw}'
    try:
        rsp = requests.get(url, timeout=5)
        rsp.raise_for_status()
    except (Exception, ) as ex:
        p(f'error: client exception -> {ex}')
        return

    # analyze API answer
    if rsp and rsp.status_code == 200:
        s = rsp.content.decode()
        j = json.loads(s)
        if not j:
            p(f'error: answer is empty, maybe bad pw, or this')
            p(f'mac {mac} is not authorized or server has no config file for it')
            return
        p(f"VPN ip received = {j['ip_vpn']}")
        p(f"VPN hub pubkey  = {j['vpn_pub_hub']}")
        fn = str(Path.home()) + '/.vpn/.this_peer.vpn_ip'
        with open(fn, 'w') as f:
            f.write(j['ip_vpn'])
        fn = str(Path.home()) + '/.vpn/.this_peer.vpn_pub_hub'
        with open(fn, 'w') as f:
            f.write(j['vpn_pub_hub'])

    else:
        p(f'error: API server seems down')


def main():
    try:
        # password from command line
        _main_cli_api_vpn(sys.argv[1])
        # do not execute anything else
        return
    except (Exception, ):
        pass

    global g_debug
    g_debug = 1
    p("we must be debugging")
    _main_cli_api_vpn("pass_when_debug")


if __name__ == '__main__':
    # $ ./ddn_cli_api_vpn.py <remote_api_pw> (vpn_api_pw_default)
    main()
