#!/usr/bin/env python3



from atu_constants import ATU_TIMEOUT_CMD_INV
from atu_cmd import atu_cmd



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# might need to apt install sshpass
# might need to install coreutils on macOS for gtimeout
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



def atu_inventory(
        network_local_or_vpn: str,
        target_all_or_req: str,
        debug: int
) -> str:

    # inventory, build list of network addresses to check
    assert network_local_or_vpn in ('local', 'vpn')
    mask_local = '192.168.0.'
    mask_vpn = '10.5.0.'
    mask = mask_local if network_local_or_vpn == 'local' else mask_vpn
    ls_ip_addr = [f'{mask}{i}' for i in range(2, 254, 1)]


    # -----------------------------------------
    # debug force inventory network and target
    # -----------------------------------------
    ls_ip_addr = ['10.5.0.12',]
    target_all_or_req = 'all'


    # command used to detect online in both target types (all /req)
    assert target_all_or_req in ('all', 'req')
    cmd_all = 'echo 1'
    cmd_req = 'redis-cli get ddh:gui:gui_beacon_flag'
    cmd = cmd_all if target_all_or_req == 'all' else cmd_req


    # run it, inventory timeout is larger in VPN that local network
    str_ls_ip_addr = ' '.join(ls_ip_addr)
    d = atu_cmd(
        cmd,
        str_ls_ip_addr,
        ATU_TIMEOUT_CMD_INV,
        debug
    )


    # refine inventory answer
    d = {k:v for k,v in d.items() if v.replace('\n', '') == '1'}
    str_inventory = ' '.join(d.keys())


    # printing allows ATUIN bash functions to communicate
    print(str_inventory)

    # returning allows python functions to communicate
    return str_inventory



# can get called by ATUIN
# if __name__ == '__main__':
#    atu_inventory('local', 'all')
