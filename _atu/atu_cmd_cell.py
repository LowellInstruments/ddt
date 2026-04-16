#!/usr/bin/env python3



from atu_cmd_custom import atu_cmd_custom
from pprint import pprint
import sys



if __name__ == '__main__':
    # _cmd = 'ls'
    # _cmd = 'cat /home/pi/li/ddh/.ddh_version'
    _cmd = "echo -ne \'AT+CVERSION\r\' > /dev/ttyUSB2 && sleep 0.2 && cat -v /dev/ttyUSB2"
    lv = sys.argv[1]
    ar = sys.argv[2]
    assert lv is not None
    assert ar is not None
    _d = atu_cmd_custom(local_or_vpn=lv, all_or_req=ar, cmd=_cmd, timeout=5)
    _d2 = _d
    for k, v in _d2.items():
        _d[k] = [i for i in v.split('\n') if '202' in i]

    pprint(_d)
