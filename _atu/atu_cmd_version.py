#!/usr/bin/env python3



from atu_cmd_custom import atu_cmd_custom
from pprint import pprint
import sys



if __name__ == '__main__':
    _cmd = 'cat /home/pi/li/ddh/.ddh_version'
    lv = sys.argv[1]
    ar = sys.argv[2]
    assert lv is not None
    assert ar is not None
    _d = atu_cmd_custom(local_or_vpn=lv, all_or_req=ar, cmd=_cmd, timeout=5)
    print('result atu_cmd_version')
    print('----------------------')
    pprint(_d)
