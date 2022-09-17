import socket
import json
import asyncio
import logging
import os
import re
import struct
import time
import traceback
from bleak import BleakScanner, BleakClient, BleakError
from bleak.backends.scanner import AdvertisementData
from bleak.backends.device import BLEDevice
from datetime import datetime
from enum import Enum

from ddh.threads.back import back
from ddh.threads.utils_core import core_set_state, STATE_BLE_DL_ONGOING

NAME_FILTER = 'ZT-MOANA-0051'
VSP_RX_CHAR_UUID = '569a2001-b87f-490c-92cb-11ba5ea5167c'
VSP_TX_CHAR_UUID = '569a2000-b87f-490c-92cb-11ba5ea5167c'

_sk = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)


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
        self.path = '/home/kaz/Downloads/'
        self.offload_file_path = self.path

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

    async def connect(self):
        def name_filter(_: BLEDevice, adv: AdvertisementData):
            if adv.local_name and adv.local_name.startswith(NAME_FILTER):
                return True
            return False

        def handle_disconnect(_: BleakClient):
            print("Disconnected")

        def handle_rx(_: int, data: bytearray):
            for i in data:
                self.packet_parse(i)

        try:
            # print('Scanning...')
            device = await BleakScanner.find_device_by_filter(name_filter, timeout=40)
        except (asyncio.TimeoutError, BleakError, OSError):
            print('An error occurred while scanning - check Bluetooth')
            return False
        try:
            if device:
                print(f'Connecting to {device.name}')
                self.client = BleakClient(device, disconnected_callback=handle_disconnect)
                if await self.client.connect():
                    await self.client.start_notify(VSP_TX_CHAR_UUID, handle_rx)
                    print('Connected')
                    return True
                print(f'Failed to connect to Moana sensor {device.name}')
            else:
                pass
                # print('Failed to find a Moana sensor')
        except (asyncio.TimeoutError, BleakError, OSError):
            print(f'An error occurred while connecting to Moana sensor {device.name}')
        return False

    async def disconnect(self):
        if self.client and self.client.is_connected:
            print('Disconnecting')
            await self.packet_write('.')
            await self.client.disconnect()

    async def authenticate(self):
        print('Authenticating')
        await self.packet_write('A123')
        if await self.packet_read('a') == '{"Authenticated":true}':
            return True
        print('Failed to authenticate')
        return False

    async def sync_time(self):
        print('Syncing time')
        self.time_sync = int(time.time())
        await self.packet_write(f'T{self.time_sync}')
        if await self.packet_read('t') == f'{{"Synchronized":{self.time_sync}}}':
            return True
        print('Failed to sync time')
        return False

    async def file_info(self):
        print('Retrieving file info')
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
            print('file size', self.offload_file_size)
            print(f'Offloading to file: {self.offload_file_name}')
            try:
                v = self.offload_file_path + self.offload_file_name
                print('---', v)
                self.offload_file = open(self.offload_file_path + self.offload_file_name, 'wb')
                return True
            except OSError:
                print(f'Failed to open offload file {self.offload_file_name}')
        return False

    async def read_data(self):
        await self.packet_write('B')
        data = await self.packet_read_binary('D')
        if len(data) > 0:
            self.offload_file.write(data)
            # progress bar
            print('.')
            v = 100 * (len(data) / self.offload_file_size)
            print('{}%'.format(v))
            _sk.sendto(str(v).encode(), ('127.0.0.1', 12349))

            return False
        else:
            print(f'\rRead {self.offload_file.tell()} Bytes')
            self.close_file()
            return True

    async def file_checksum(self):
        print('Checking checksum')
        await self.packet_write('Z')
        moana_checksum_str = await self.packet_read('z')
        moana_checksum = int(moana_checksum_str, 16)
        file_checksum = 0

        self.offload_file = open(self.offload_file_path + self.offload_file_name, 'rb')
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
            print('File checksum does not match')
            return False
        print('File checksum matches')
        return True

    async def clear_data(self):
        print('Clearing file from Moana')
        await self.packet_write('C')
        return await self.packet_read('c') == '{"ArchiveBit":false}'

    def close_file(self):
        if self.offload_file is not None:
            self.offload_file.close()

    def decode(self):
        with open(self.offload_file_path + self.offload_file_name, 'rb') as bin_file:
            csv_file_name = self.path + os.path.splitext(self.offload_file_name)[0] + '.csv'
            print(f'Decoding to file: {csv_file_name}')
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
                        print('Unexpected number of bytes')
                        break
                    values = struct.unpack('<3H', data)

                    timestamp += values[0]
                    csv_file.write(f'{datetime.utcfromtimestamp(timestamp).strftime("%d/%m/%Y,%H:%M:%S")},'.encode())

                    depth = (values[1] / 10) - 10
                    csv_file.write(f'{depth:.1f},'.encode())

                    temp = (values[2] / 1000) - 10
                    csv_file.write(f'{temp:.3f}\n'.encode())

                    data = bin_file.read(6)
        print(f'Decoding finished')

    async def download_recipe(self):

        # for GUI refresh
        back['ble']['downloading'] = True

        # call connect to logger
        status = await self.connect()
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
                    print('Timed out during offload')
                    break

            if offload_state == OffloadState.AUTHENTICATE:
                print('Status file changed to 0')

                g = open(self.path + 'status.txt', 'w')
                g.write('0')
                g.close()

                status = await self.authenticate()
                offload_state = OffloadState.SYNC_TIME
            elif offload_state == OffloadState.SYNC_TIME:
                status = await self.sync_time()
                offload_state = OffloadState.FILE_INFO
            elif offload_state == OffloadState.FILE_INFO:
                status = await self.file_info()
                offload_state = OffloadState.READ_DATA
            elif offload_state == OffloadState.READ_DATA:
                if await self.read_data():
                    offload_state = OffloadState.CHECKSUM
            elif offload_state == OffloadState.CHECKSUM:
                status = await self.file_checksum()
                offload_state = OffloadState.CLEAR_DATA
            elif offload_state == OffloadState.CLEAR_DATA:
                # todo > reenable these
                # await self.clear_data()
                await self.disconnect()
                offload_state = OffloadState.COMPLETE
                # todo > remove this
                break

        if offload_state == OffloadState.COMPLETE:
            self.decode()
            # progress bar
            v = 100
            print('{}%'.format(v))
            _sk.sendto(str(v).encode(), ('127.0.0.1', 12349))

            # todo > why this? it was sleep 20
            time.sleep(5)
            g = open(self.path + 'status.txt', 'w')
            g.write('1')
            g.close()
            print('Offload succeeded')
            return True
        else:
            await self.disconnect()
            self.close_file()
            # print('Offload failed')

        # progress bar
        v = 0
        print('{}%'.format(v))
        _sk.sendto(str(v).encode(), ('127.0.0.1', 12349))
        return False


# def bleak_moana():
#     try:
#         moana_ble = MoanaBle()
#         rv = asyncio.run(moana_ble.download_recipe())
#         print('bye, bye')
#         return rv
#     except Exception as e:
#         logging.error(traceback.format_exc())


async def bleak_moana():
    try:
        moana_ble = MoanaBle()
        rv = await moana_ble.download_recipe()
        print('bye, bye', rv)
        return rv
    except Exception as e:
        logging.error(traceback.format_exc())


async def bleak_moana_main():
    return await bleak_moana()

# todo >test icons
# todo > test several exes in a row async

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    coroutine = bleak_moana_main()
    loop.run_until_complete(coroutine)
    time.sleep(1)
    print('puta')
    coroutine = bleak_moana_main()
    loop.run_until_complete(coroutine)



# tests, several runs in a row
