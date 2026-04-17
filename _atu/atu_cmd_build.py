#!/usr/bin/env python3



from atu_cmd import atu_cmd
from atu_inv import atu_inventory



def atu_cmd_build(
        network_local_or_vpn: str,
        target_all_or_req: str,
        cmd: str,
        timeout: int,
        debug: int
) -> dict:

    str_inventory = atu_inventory(
        network_local_or_vpn,
        target_all_or_req,
        debug
    )
    d_ans = atu_cmd(
        cmd,
        str_inventory,
        timeout,
        debug
    )
    return d_ans




