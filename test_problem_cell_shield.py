import time
from gpiozero import LED
import serial



def _gps_know_hat_firmware_version():

    _sp = None
    ans = bytes()
    try:
        _sp = serial.Serial(
            "/dev/ttyUSB2", baudrate=115200,
            timeout=1, rtscts=True, dsrdtr=True
        )
        _sp.flushInput()
        _sp.readall()
        _sp.write(b"AT+CVERSION\r")
        ans = _sp.readall()
        
        # print(ans)
        # ans: b'\r\nVERSION: EC25AFAR05A07M4G\r\nAug 18 2022 15:28:42\r\nAuthors: QCT\r\n\r\nOK\r\n\r\n+CREG: 0,2\r\n\r\nOK\r\n'

        if b'OK' in ans or b'VERSION' in ans or b'QCT' in ans:
            print(ans)

    except (Exception,) as ex:
        print(f"error: hat_firmware_version -> {ex}")

    finally:
        if _sp:
            _sp.close()
        return ans




def _gps_power_cycle():

    rv_firm = _gps_know_hat_firmware_version()
    if not rv_firm:
        print('error: cannot run this test, cannot detect cell shield')
        return
    print("detected cell shield")


    # GPIO26 = on() means high-level, shutdowns power to hat
    # GPIO26 = off() means low-level, restores power to hat
    _pin12 = LED(12)
    _pin26 = LED(26)
    _pin26.on()
    _pin12.on()
    time.sleep(3)
    rv_firm = _gps_know_hat_firmware_version()
    # print(f'rv_firm = {rv_firm}')
    time.sleep(2)
    _pin26.off()
    _pin12.off()
    
    if rv_firm:
        print("=== warning: answer when NOT expected, DDH needs wire to be able to power cycle")
    else:
        t = 75
        print(f"=== success: DDH capable of power-cycle, wait ~{t} seconds ===")
        time.sleep(t)





def main():
    _gps_power_cycle()




if __name__ == '__main__':
    main()
