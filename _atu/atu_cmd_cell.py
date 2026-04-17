#!/usr/bin/env python3



from atu_constants import ATU_TIMEOUT_CMD_CELL
from atu_cmd_build import atu_cmd_build
from pprint import pprint
import sys



if __name__ == '__main__':

    _cmd = "echo -ne \'AT+CVERSION\\r\' > /dev/ttyUSB2 && sleep 0.1 && cat -v /dev/ttyUSB2"
    network_local_or_vpn = sys.argv[1]
    target_all_or_req = sys.argv[2]
    debug = sys.argv[3]
    _d = atu_cmd_build(
        network_local_or_vpn,
        target_all_or_req,
        _cmd,
        ATU_TIMEOUT_CMD_CELL,
        int(debug)
    )

    # filter cell command results
    _d2 = _d
    for k, v in _d2.items():
        _d[k] = [i for i in v.split('\n') if '202' in i]

    print('\n---------------------------------')
    print(f'result cmd_cell w/ parameters')
    print(f'network = {network_local_or_vpn}, target = {target_all_or_req}')
    print('---------------------------------')
    pprint(_d)