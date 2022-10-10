import socket
import json
import asyncio
import logging
import os
import re
import struct
import time
import traceback
from bleak import BleakClient, BleakError
from datetime import datetime
from enum import Enum
from ddh.threads.back import back
from ddh.threads.utils_core import core_set_state, STATE_BLE_DL_ONGOING
from ddh.threads.utils_ddh import get_dl_folder_path_from_mac, create_folder_logger_by_mac
from ddh.threads.utils_logs import l_i_, l_e_, l_d_


VSP_RX_CHAR_UUID = '569a2001-b87f-490c-92cb-11ba5ea5167c'
VSP_TX_CHAR_UUID = '569a2000-b87f-490c-92cb-11ba5ea5167c'

_sk = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
_g_data_progress = 0


# -----------------------------------
# Moana file for old version of DDH
# -----------------------------------


class OffloadState(Enum):
    CONNECT = 0
    AUTHENTICATE = 1
    SYNC_TIME = 2
    FILE_INFO = 3
    READ_DATA = 4
    CHECKSUM = 5
    CLEAR_DATA = 6
    COMPLETE = 7


class PacketState(Enum):
    IDLE = 0
    LENGTH = 1
    ADDRESS = 2
    RESERVED = 3
    BODY = 4
    COMPLETE = 5


class MoanaBle:
    def __init__(self):
        self.client = None
        self.packet_state = PacketState.IDLE
        self.packet_length = 0
        self.packet_length_buff = ''
        self.packet_address = ''
        self.packet_body = bytearray()
        self.time_sync = None
        self.offload_file = None
        self.offload_file_name = ''
        self.offload_file_size = 0
        self.mac = ''

    async def packet_write(self, data: str):
        self.packet_reset()
        length = chr(ord('A') + len(data))
        await self.client.write_gatt_char(VSP_RX_CHAR_UUID, f'*{length}{data}'.encode())

    async def packet_complete(self, timeout: int = 60):
        while (self.packet_state != PacketState.COMPLETE) and \
                (self.client and self.client.is_connected) and \
                (timeout > 0):
            await asyncio.sleep(0.1)
            timeout -= 0.1

    async def packet_read(self, address: str):
        await self.packet_complete()
        if self.packet_address != address:
            return ''
        return self.packet_body.decode()

    async def packet_read_binary(self, address: str):
        await self.packet_complete()
        if self.packet_address != address:
            return bytearray()
        return self.packet_body

    def packet_reset(self):
        self.packet_state = PacketState.IDLE
        self.packet_length = 0
        self.packet_length_buff = ''
        self.packet_address = ''
        self.packet_body = bytearray()

    def packet_parse(self, byte: int):
        if self.packet_state == PacketState.IDLE:
            if chr(byte) == '*':
                self.packet_state = PacketState.LENGTH
        elif self.packet_state == PacketState.LENGTH:
            if len(self.packet_length_buff) == 0 and 'A' <= chr(byte) <= 'Z':
                self.packet_length = byte - ord('A')
                self.packet_state = PacketState.ADDRESS
            else:
                self.packet_length_buff += chr(byte)
                if len(self.packet_length_buff) == 4:
                    self.packet_length = int(self.packet_length_buff, 16) - 4
                    self.packet_state = PacketState.ADDRESS
        elif self.packet_state == PacketState.ADDRESS:
            self.packet_address = chr(byte)
            self.packet_length -= 1
            if self.packet_length <= 0:
                self.packet_state = PacketState.COMPLETE
                return
            elif len(self.packet_length_buff) == 4:
                self.packet_state = PacketState.RESERVED
            else:
                self.packet_state = PacketState.BODY
        elif self.packet_state == PacketState.RESERVED:
            # discard reserved byte
            self.packet_state = PacketState.BODY
        elif self.packet_state == PacketState.BODY:
            self.packet_body.append(byte)
            self.packet_length -= 1
            if self.packet_length <= 0:
                self.packet_state = PacketState.COMPLETE

    async def connect(self, mac):

        def handle_disconnect(_: BleakClient):
            l_i_("[ BLE ] moana disconnected")

        def handle_rx(_: int, data: bytearray):
            for i in data:
                self.packet_parse(i)

        try:
            l_i_('[ BLE ] Connecting to {}'.format(mac))
            self.client = BleakClient(mac, disconnected_callback=handle_disconnect)
            if await self.client.connect():
                self.mac = mac
                await self.client.start_notify(VSP_TX_CHAR_UUID, handle_rx)
                l_i_('[ BLE ] Connected')
                return True
            l_e_('[ BLE ] Failed to connect to Moana sensor {}'.format(mac))
        except (asyncio.TimeoutError, BleakError, OSError):
            l_e_('[ BLE ] An error occurred while connecting to Moana sensor {}'.format(mac))
        return False

    async def disconnect(self):
        if self.client and self.client.is_connected:
            l_i_('[ BLE ] Disconnecting')
            await self.packet_write('.')
            await self.client.disconnect()

    async def authenticate(self):
        l_i_('[ BLE ] authenticating')
        await self.packet_write('A123')
        if await self.packet_read('a') == '{"Authenticated":true}':
            return True
        l_e_('[ BLE ] error to moana authenticate')
        return False

    async def sync_time(self):
        l_i_('Syncing time')
        self.time_sync = int(time.time())
        await self.packet_write(f'T{self.time_sync}')
        if await self.packet_read('t') == f'{{"Synchronized":{self.time_sync}}}':
            return True
        l_e_('[ BLE ] failed to sync time')
        return False

    async def file_info(self):
        l_i_('Retrieving file info')
        await self.packet_write('F')
        rsp = await self.packet_read('F')
        match = re.search(r'{"FileName":"(.*)","FileSizeEstimate":(.*),"ArchiveBit":"(.*)"}', rsp)
        self.offload_file_size = 0
        if match is not None:
            file_name_parts = os.path.splitext(match[1])
            time_str = datetime.utcfromtimestamp(self.time_sync).strftime('%y%m%d%H%M%S')
            self.offload_file_name = f'{file_name_parts[0]}_{time_str}.bin'
            rsp_as_dict = json.loads(rsp)
            self.offload_file_size = int(rsp_as_dict['FileSizeEstimate'])
            l_i_('[ BLE ] moana offloading to {} size {}'.format(self.offload_file_name, self.offload_file_size))
            try:
                v = str(get_dl_folder_path_from_mac(self.mac)) + '/' + self.offload_file_name
                create_folder_logger_by_mac(self.mac)
                self.offload_file = open(v, 'wb')
                return True
            except OSError:
                l_e_('failed to open offload file {}'.format(self.offload_file_name))
        return False

    async def read_data(self):
        await self.packet_write('B')
        data = await self.packet_read_binary('D')
        if len(data) > 0:
            # moana sizes from file_info() is of the CSV file (~5 factor)
            global _g_data_progress
            _g_data_progress += (len(data) * 5)
            self.offload_file.write(data)
            # progress bar
            v = 100 * (_g_data_progress / self.offload_file_size)
            l_d_('[ BLE ] moana file download progress {}%'.format(int(v)))
            _sk.sendto(str(v).encode(), ('127.0.0.1', 12349))
            # still more file to receive
            return False

        # end receiving
        self.close_file()
        return True

    async def file_checksum(self):
        l_i_('[ BLE ] moana checking checksum')
        await self.packet_write('Z')
        moana_checksum_str = await self.packet_read('z')
        moana_checksum = int(moana_checksum_str, 16)
        file_checksum = 0

        v = str(get_dl_folder_path_from_mac(self.mac)) + '/' + self.offload_file_name
        self.offload_file = open(v, 'rb')
        while True:
            byte = self.offload_file.read(1)
            if not byte:
                break
            file_checksum = (file_checksum ^ ord(byte)) & 0xFFFFFFFF
            file_checksum = (file_checksum << 1) & 0xFFFFFFFF
            if file_checksum & 0x80000000:
                file_checksum = (file_checksum | 1) & 0xFFFFFFFF
        self.offload_file.close()

        if file_checksum != moana_checksum:
            l_e_('[ BLE ] moana File checksum does not match')
            return False
        return True

    async def clear_data(self):
        l_d_('[ BLE ] clearing file from Moana')
        await self.packet_write('C')
        return await self.packet_read('c') == '{"ArchiveBit":false}'

    def close_file(self):
        if self.offload_file is not None:
            self.offload_file.close()

    def decode(self):

        v = str(get_dl_folder_path_from_mac(self.mac)) + '/' + self.offload_file_name
        with open(v, 'rb') as bin_file:
            csv_file_name = v[:-3] + 'csv'
            l_i_('[ BLE ] decoding moana file {}'.format(csv_file_name))
            with open(csv_file_name, 'wb') as csv_file:
                # header
                data = bin_file.read(1)
                while data and data != b'\x03':
                    csv_file.write(data)
                    data = bin_file.read(1)

                # origin time
                timestamp = struct.unpack('<i', bin_file.read(4))[0]

                data = bin_file.read(6)
                while data:
                    if len(data) != 6:
                        l_e_('[ BLE ] moana Unexpected number of bytes')
                        break
                    values = struct.unpack('<3H', data)

                    timestamp += values[0]
                    csv_file.write(f'{datetime.utcfromtimestamp(timestamp).strftime("%d/%m/%Y,%H:%M:%S")},'.encode())

                    depth = (values[1] / 10) - 10
                    csv_file.write(f'{depth:.1f},'.encode())

                    temp = (values[2] / 1000) - 10
                    csv_file.write(f'{temp:.3f}\n'.encode())

                    data = bin_file.read(6)
        l_i_('[ BLE ] decoding finished')

    async def download_recipe(self, mac):

        # for GUI refresh
        back['ble']['downloading'] = True

        # call connect to logger
        status = await self.connect(mac)
        last_state = OffloadState.CONNECT
        offload_state = OffloadState.AUTHENTICATE
        state_time = datetime.now()

        core_set_state(STATE_BLE_DL_ONGOING)

        while status and self.client and self.client.is_connected:
            if offload_state != last_state:
                last_state = offload_state
                state_time = datetime.now()
            else:
                if (datetime.now() - state_time).total_seconds() > 600:
                    l_e_('[ BLE ] moana error: Timed out during offload')
                    break

            if offload_state == OffloadState.AUTHENTICATE:
                status = await self.authenticate()
                offload_state = OffloadState.SYNC_TIME
            elif offload_state == OffloadState.SYNC_TIME:
                status = await self.sync_time()
                offload_state = OffloadState.FILE_INFO
            elif offload_state == OffloadState.FILE_INFO:
                status = await self.file_info()
                offload_state = OffloadState.READ_DATA
                global _g_data_progress
                _g_data_progress = 0
            elif offload_state == OffloadState.READ_DATA:
                if await self.read_data():
                    offload_state = OffloadState.CHECKSUM
            elif offload_state == OffloadState.CHECKSUM:
                status = await self.file_checksum()
                offload_state = OffloadState.CLEAR_DATA
            elif offload_state == OffloadState.CLEAR_DATA:
                await self.clear_data()
                await self.disconnect()
                offload_state = OffloadState.COMPLETE
                break

        if offload_state == OffloadState.COMPLETE:
            self.decode()
            # progress bar
            v = 100
            l_d_('[ BLE ] moana file download progress {}%'.format(int(v)))
            _sk.sendto(str(v).encode(), ('127.0.0.1', 12349))

            time.sleep(5)
            l_i_('[ BLE ] Offload succeeded')
            return True

        # did not go well
        await self.disconnect()
        self.close_file()
        l_e_('[ BLE ] moana Offload failed')

        # progress bar reset
        v = 0
        _sk.sendto(str(v).encode(), ('127.0.0.1', 12349))
        return False


async def bleak_moana(mac):
    try:
        moana_ble = MoanaBle()
        rv = await moana_ble.download_recipe(mac)
        l_d_('[ BLE ] moana download_recipe rv = {}'.format(rv))
        return rv

    except Exception as e:
        logging.error(traceback.format_exc())


async def bleak_moana_main(mac):
    return await bleak_moana(mac)
