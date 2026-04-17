#!/usr/bin/env python3



from atu_constants import ATU_TIMEOUT_CMD_VER
from atu_cmd_build import atu_cmd_build
from pprint import pprint
import sys



if __name__ == '__main__':

    _cmd = 'cat /home/pi/li/ddh/.ddh_version'
    network_local_or_vpn = sys.argv[1]
    target_all_or_req = sys.argv[2]
    debug = sys.argv[3]
    _d = atu_cmd_build(
        network_local_or_vpn,
        target_all_or_req,
        _cmd,
        ATU_TIMEOUT_CMD_VER,
        int(debug)
    )

    # filter version command answer
    _d2 = _d
    for k, v in _d2.items():
        _d[k] = 'v' + v.replace('\n', '')

    print('\n---------------------------------')
    print(f'result cmd_version w/ parameters')
    print(f'network = {network_local_or_vpn}, target = {target_all_or_req}')
    print('---------------------------------')
    pprint(_d)
