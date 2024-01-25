#!/usr/bin/env python3


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
