#!/usr/bin/env python3



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# might need to apt install sshpass
# might need to install coreutils on macOS for gtimeout
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



from atu_cmd import atu_cmd



def atu_inventory(
        local_or_vpn: str,
        all_or_req: str
) -> str:

    # inventory list of addresses to check
    assert local_or_vpn in ('local', 'vpn')
    mask_local = '192.168.0.'
    mask_vpn = '10.5.0.'
    mask = mask_local if local_or_vpn == 'local' else mask_vpn
    ls_ip_addr = [f'{mask}{i}' for i in range(2, 254, 1)]

    # ------
    # debug
    # ------
    # local_or_vpn = 'vpn'
    # ls_ip_addr = ['10.5.0.12', '10.5.0.12']


    # inventory command used to detect online
    assert all_or_req in ('all', 'req')
    cmd_all = 'echo 1'
    cmd_req = 'redis-cli get ddh:gui:gui_beacon_flag'
    cmd = cmd_all if all_or_req == 'all' else cmd_req


    # run it, inventory is slower on VPN
    str_ls_ip_addr = ' '.join(ls_ip_addr)
    timeout_cmd = 1 if local_or_vpn == 'local' else 5
    d = atu_cmd(cmd, str_ls_ip_addr, timeout_cmd=timeout_cmd)


    # refine inventory answer for inventory command
    d = {k:v for k,v in d.items() if v.replace('\n', '') == '1'}
    str_inventory = ' '.join(d.keys())


    # printing allows ATUIN bash functions to communicate
    print(str_inventory)

    # returning allows python functions to communicate
    return str_inventory



# can get called by ATUIN
# if __name__ == '__main__':
#    atu_inventory('local', 'all')
