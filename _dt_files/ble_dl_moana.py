import pathlib
import socket
import json
import asyncio
import os
import re
import struct
import time
import traceback

from bleak import BleakClient, BleakError
from datetime import datetime
from enum import Enum

from dds.emolt import (
    file_moana_raw_csv_to_emolt_csv,
    ddh_is_emolt_box,
    file_emolt_csv_to_hl,
    file_out_hl_process_xc_85,
)
from dds.rbl import rbl_build_emolt_msg_as_str, rbl_gen_file, rbl_hex_str_to_hex_bytes
from mat.utils import linux_is_rpi
from utils.ddh_shared import (
    create_folder_logger_by_mac,
)
from utils.logs import lg_dds as lg
from mat.ble.ble_mat_utils import ble_mat_progress_dl


VSP_RX_CHAR_UUID = "569a2001-b87f-490c-92cb-11ba5ea5167c"
VSP_TX_CHAR_UUID = "569a2000-b87f-490c-92cb-11ba5ea5167c"

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
    def __init__(self, fol, g, h="hci0"):
        self.cli = None
        self.packet_state = PacketState.IDLE
        self.packet_length = 0
        self.packet_length_buff = ""
        self.packet_address = ""
        self.packet_body = bytearray()
        self.time_sync = None
        self.offload_file = None
        self.offload_file_name = ""
        self.offload_file_size = 0
        self.offload_file_path = ""
        self.offload_file_folder = fol
        self.h = h
        self.mac = ""
        os.makedirs(str(self.offload_file_folder), exist_ok=True)
        self.lat = g[0]
        self.lon = g[1]

    async def packet_write(self, data: str):
        self.packet_reset()
        length = chr(ord("A") + len(data))
        await self.cli.write_gatt_char(VSP_RX_CHAR_UUID, f"*{length}{data}".encode())

    async def packet_complete(self, timeout: int = 60):
        while (
            (self.packet_state != PacketState.COMPLETE)
            and (self.cli and self.cli.is_connected)
            and (timeout > 0)
        ):
            await asyncio.sleep(0.1)
            timeout -= 0.1

    async def packet_read(self, address: str):
        await self.packet_complete()
        if self.packet_address != address:
            return ""
        return self.packet_body.decode()

    async def packet_read_binary(self, address: str):
        await self.packet_complete()
        if self.packet_address != address:
            return bytearray()
        return self.packet_body

    def packet_reset(self):
        self.packet_state = PacketState.IDLE
        self.packet_length = 0
        self.packet_length_buff = ""
        self.packet_address = ""
        self.packet_body = bytearray()

    def packet_parse(self, byte: int):
        if self.packet_state == PacketState.IDLE:
            if chr(byte) == "*":
                self.packet_state = PacketState.LENGTH
        elif self.packet_state == PacketState.LENGTH:
            if len(self.packet_length_buff) == 0 and "A" <= chr(byte) <= "Z":
                self.packet_length = byte - ord("A")
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
        def cb_disc(_: BleakClient):
            print("Disconnected")

        def handle_rx(_: int, data: bytearray):
            for i in data:
                self.packet_parse(i)

        try:
            self.cli = BleakClient(
                mac, adapter=self.h, adapterdisconnected_callback=cb_disc
            )
            if await self.cli.connect():
                self.mac = mac
                self.cli._mtu_size = 100
                # print('mtu {}'.format(self.cli.mtu_size))
                await self.cli.start_notify(VSP_TX_CHAR_UUID, handle_rx)
                return 0

        except (asyncio.TimeoutError, BleakError, OSError) as er:
            lg.a("error: failed connecting {}".format(mac))
            lg.a("error: {}".format(er))
        return 1

    async def disconnect(self):
        if self.cli and self.cli.is_connected:
            self.mac = ""
            print("Disconnecting")
            await self.packet_write(".")
            await self.cli.disconnect()

    async def authenticate(self):
        print("Authenticating")
        await self.packet_write("A123")
        if await self.packet_read("a") == '{"Authenticated":true}':
            return True
        print("Failed to authenticate")
        return False

    async def sync_time(self):
        print("Syncing time")
        self.time_sync = int(time.time())
        await self.packet_write(f"T{self.time_sync}")
        if await self.packet_read("t") == f'{{"Synchronized":{self.time_sync}}}':
            return True
        print("Failed to sync time")
        return False

    async def file_info(self):
        print("Retrieving file info")
        await self.packet_write("F")
        rsp = await self.packet_read("F")
        match = re.search(
            r'{"FileName":"(.*)","FileSizeEstimate":(.*),"ArchiveBit":"(.*)"}', rsp
        )
        self.offload_file_size = 0
        if match is not None:
            file_name_parts = os.path.splitext(match[1])
            time_str = datetime.utcfromtimestamp(self.time_sync).strftime(
                "%y%m%d%H%M%S"
            )

            # ------------------------
            # name of moana file .bin
            # ------------------------

            self.offload_file_name = f"{file_name_parts[0]}_{time_str}.bin"
            rsp_as_dict = json.loads(rsp)
            self.offload_file_size = int(rsp_as_dict["FileSizeEstimate"])
            print("csv approx. file size", self.offload_file_size)
            print(f"Offloading to file: {self.offload_file_name}")
            try:
                self.offload_file_path = str(
                    pathlib.Path(self.offload_file_folder) / self.offload_file_name
                )
                self.offload_file = open(self.offload_file_path, "wb")
                return True

            except OSError:
                print(f"Failed to open offload file {self.offload_file_name}")
        return False

    async def read_data(self):
        await self.packet_write("B")
        data = await self.packet_read_binary("D")
        if len(data) > 0:

            # --------------------------------
            # actual write of moana file .bin
            # ---------------------------------

            self.offload_file.write(data)
            ble_mat_progress_dl(len(data), self.offload_file_size)
            return False
        else:
            print(f"\rRead {self.offload_file.tell()} Bytes")
            self.close_file()
            return True

    async def file_checksum(self):
        print("Checking checksum")
        await self.packet_write("Z")
        moana_checksum_str = await self.packet_read("z")
        moana_checksum = int(moana_checksum_str, 16)
        file_checksum = 0

        self.offload_file = open(self.offload_file_path, "rb")
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
            print("File checksum does not match")
            return False
        print("File checksum matches")
        return True

    async def clear_data(self):
        print("Clearing file from Moana")
        await self.packet_write("C")
        return await self.packet_read("c") == '{"ArchiveBit":false}'

    def close_file(self):
        if self.offload_file is not None:
            self.offload_file.close()

    def _generate_lowell_csv_files(self):

        # paths and columns
        dl_file_path = self.offload_file_path
        p = dl_file_path.replace(".bin", ".csv")
        create_folder_logger_by_mac(self.mac)
        pt = p[:-4] + "_Temperature.csv"
        pp = p[:-4] + "_Pressure.csv"
        cols = "Date,Time,Depth Decibar,Temperature C\n"

        # open source and destination files
        with open(p, "r") as f:
            lines = f.readlines()
        ft = open(pt, "w")
        fp = open(pp, "w")
        ft.write("ISO 8601 Time,Temperature (C)\n")
        fp.write("ISO 8601 Time,Pressure (dbar)\n")

        # grab only the data rows of source file
        idx_data = lines.index(cols)
        lines_data = lines[idx_data + 1 :]
        for i in lines_data:
            i = i.replace("\n", "")
            mmddyyyy, hhmmss, p, t = i.split(",")
            mm, dd, yyyy = mmddyyyy.split("/")
            _ = "{}-{}-{}T{}.000".format(yyyy, mm, dd, hhmmss)
            # split and write proper data rows to destination files
            ft.write("{},{}\n".format(_, t))
            fp.write("{},{}\n".format(_, p))
        ft.close()
        fp.close()

    def generate_lowell_csv_files(self):
        try:
            return self._generate_lowell_csv_files()
        except (Exception,) as ex:
            lg.a("error: generate li csv files for moana -> {}".format(ex))

    def decode(self):
        dl_file_path = self.offload_file_path
        csv_file_path = dl_file_path.replace(".bin", ".csv")

        with open(dl_file_path, "rb") as bin_file:
            print(f"Decoding to file: {csv_file_path}")
            with open(csv_file_path, "wb") as csv_file:
                # header
                data = bin_file.read(1)
                while data and data != b"\x03":
                    csv_file.write(data)
                    data = bin_file.read(1)

                # origin time
                timestamp = struct.unpack("<i", bin_file.read(4))[0]

                data = bin_file.read(6)
                while data:
                    if len(data) != 6:
                        print("Unexpected number of bytes")
                        break
                    values = struct.unpack("<3H", data)

                    timestamp += values[0]
                    csv_file.write(
                        f'{datetime.utcfromtimestamp(timestamp).strftime("%d/%m/%Y,%H:%M:%S")},'.encode()
                    )

                    depth = (values[1] / 10) - 10
                    csv_file.write(f"{depth:.1f},".encode())

                    temp = (values[2] / 1000) - 10
                    csv_file.write(f"{temp:.3f}\n".encode())

                    data = bin_file.read(6)
        print("Decoding finished")

    async def download_recipe(self, mac):

        till = time.perf_counter() + 30
        while 1:
            if time.perf_counter() > till:
                lg.a("moana timeout! could not connect to {}".format(mac))
                return False
            try:
                if await self.connect(mac) == 0:
                    # going well :)
                    break
            except (Exception,) as ex:
                lg.a("error: moana connect exception {}".format(ex))
                time.sleep(1)

        status = True
        last_state = OffloadState.CONNECT
        offload_state = OffloadState.AUTHENTICATE
        state_time = datetime.now()

        while status and self.cli and self.cli.is_connected:
            if offload_state != last_state:
                last_state = offload_state
                state_time = datetime.now()
            else:
                if (datetime.now() - state_time).total_seconds() > 600:
                    print("Timed out during offload")
                    break

            if offload_state == OffloadState.AUTHENTICATE:
                print("Status file changed to 0")
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
                await self.clear_data()
                await self.disconnect()
                offload_state = OffloadState.COMPLETE
                break

        if offload_state == OffloadState.COMPLETE:

            # ---------------------------------
            # generates Moana output CSV file
            # ---------------------------------
            self.decode()

            # ----------------------------------
            # generates custom output CSV files
            # ----------------------------------
            if ddh_is_emolt_box() or not linux_is_rpi():
                lg.a("emolt box detected, converting Moana CSV file to emolt format")
                file_emolt_zt_csv = file_moana_raw_csv_to_emolt_csv(
                    self.offload_file_path, self.lat, self.lon
                )
                hl_csv_file = file_emolt_csv_to_hl(
                    file_emolt_zt_csv, logger_type="moana"
                )
                x85 = file_out_hl_process_xc_85(hl_csv_file)
                ms = rbl_build_emolt_msg_as_str(self.lat, self.lon, x85)
                mb = rbl_hex_str_to_hex_bytes(ms)
                rbl_gen_file(mb)

            # Lowell files always generated, needed for plotting at least
            lg.a("NOT emolt box detecting, converting file to LI format")
            self.generate_lowell_csv_files()

            # indicate 100% download
            v = self.offload_file_size
            ble_mat_progress_dl(v, v)
            time.sleep(5)
            print("Offload succeeded")
            return True

        # went south
        await self.disconnect()
        self.close_file()
        print("Offload failed")
        ble_mat_progress_dl(0, self.offload_file_size)
        return False


async def ble_interact_moana(dl_folder, mac, h, g):
    lc = MoanaBle(dl_folder, g, h)
    try:
        lg.a("interacting with Moana logger, mac {}".format(mac))
        if lc:
            rv = await lc.download_recipe(mac)
            if not rv:
                return 1
            return 0

    except Exception as ex:
        lg.a("error: dl_moana_exception -> {}".format(ex))
        lg.a("error: traceback -> {}".format(traceback.print_exc()))
        await lc.disconnect()
        return 1
