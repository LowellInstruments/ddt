import asyncio
# these are relative to DDH app, not DDT, don't worry if they appear wrong
from utils.ddh_shared import (
    send_ddh_udp_gui as _u,
    STATE_DDS_BLE_ERROR_MOANA_PLUGIN,
)
from utils.logs import lg_dds as lg


async def ble_interact_moana(*args):
    lg.a("error: need to install Moana plugin")
    _u(STATE_DDS_BLE_ERROR_MOANA_PLUGIN)
    await asyncio.sleep(5)
    return 99


def check_moana_plugin_is_missing(v):
    return v == 99
