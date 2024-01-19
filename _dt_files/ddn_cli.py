#!/usr/bin/env python3

import os
import re
import sys

from getmac import get_mac_address
import requests


# ------------------------------------------------
# client password embedded as url query parameter
# ------------------------------------------------
API_PW = sys.argv[1]
API_EP = 'conf_provider'
API_PORT = 9000
API_IP = 'ddn.lowellinstruments.com'


def p(s):
    print(f'DDN cli | {s}')


def _get_filename_from_content_disposition_header(cd):
    # src: codementor, downloading-files-from-urls-in-python-77q3bs0un
    if not cd:
        return None
    s = re.findall('filename=(.+)', cd)
    if len(s) == 0:
        return None
    return s[0].replace('"', '')


def main():
    assert API_PW
    mac = get_mac_address(interface="wlan0")
    if not mac:
        p('error: no interface wlan0')
        return
    mac = mac.replace(':', '-')
    url = f'http://{API_IP}:{API_PORT}/{API_EP}/{mac}?pw={API_PW}'
    try:
        # ----------------------------------------
        # send client request for this mac address
        # ----------------------------------------
        rsp = requests.get(url, timeout=5)
        rsp.raise_for_status()
    except (Exception, ) as ex:
        p(f'error: client exception -> {ex}')
    else:
        if rsp and rsp.status_code == 200:
            h = rsp.headers.get('content-disposition')
            fn = _get_filename_from_content_disposition_header(h)
            if rsp.content == b'null':
                # p.e: bad mac or wrong password
                p('error: got API answer, but no file')
                return
            p(f'OK: API file {fn} saved in {os.getcwd()}')
            with open(fn, 'wb') as f:
                f.write(rsp.content)
        else:
            p(f'error: API server seems down')


if __name__ == "__main__":
    main()
