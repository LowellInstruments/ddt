#!/usr/bin/env python3



from atu_cmd import atu_cmd
from atu_inv import atu_inventory



def atu_cmd_custom(
        local_or_vpn: str,
        all_or_req: str,
        cmd: str,
        timeout: int = 1
) -> dict:

    str_inventory = atu_inventory(local_or_vpn, all_or_req)
    d_ans = atu_cmd(cmd, str_inventory, timeout_cmd=timeout)
    return d_ans




