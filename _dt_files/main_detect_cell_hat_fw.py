import time
import serial
from serial.tools import list_ports


VID_PID_GPS_HAT = "2C7C:0125"



def _gps_hat_flush(ser):
    if ser:
        ser.read(ser.in_waiting)


def gps_hat_get_firmware_version(usb_port):
    # usb_port: '/dev/ttyUSB2'
    ser = None
    rv = 0

    try:
        # todo: test this dummy read
        ser = serial.Serial(usb_port, baudrate=115200, timeout=0)
        _gps_hat_flush(ser)
        for _ in range(3):
            # probably echo activated so will receive back this
            ser.write(b'AT+CVERSION\r')
            time.sleep(.1)
        bb = ser.read(ser.in_waiting)
        print('\nanswer from hat: ', bb.decode())

    except (Exception,) as ex:
        print(f'GPS: error gps_hat_init -> {ex}')

    finally:
        if ser:
            ser.close()

    return rv



def gps_hat_detect_list_of_usb_ports():
    _ls = []
    for port, _, vp in sorted(list(list_ports.comports())):
        if not VID_PID_GPS_HAT in vp:
            continue
        _ls.append(port)
        # ls: ['/dev/ttyUSB0' ... '/dev/ttyUSB3']
    return _ls



if __name__ == '__main__':
    ls = gps_hat_detect_list_of_usb_ports()
    if not ls:
        print('error, cannot get HAT firmware version')
    else:
        gps_hat_get_firmware_version(ls[2])