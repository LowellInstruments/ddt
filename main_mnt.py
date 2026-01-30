import subprocess as sp
import time

import serial.tools.list_ports
import boto3

VP_QUECTEL = '2c7c:0125'


def find_n_list_all_usb_port_automatically(vp):
    # vp: vid_pid -> '1234:5678'
    # vp
    vp = vp.upper()
    ls = []
    for p in serial.tools.list_ports.comports():
        info = dict({"Name": p.name,
                     "Description": p.description,
                     "Manufacturer": p.manufacturer,
                     "Hwid": p.hwid})
        if vp in info['Hwid']:
            ls.append('/dev/' + info['Name'])
    return ls


def _get_sim_iccid():
    ls = find_n_list_all_usb_port_automatically(VP_QUECTEL)
    if not ls:
        return 'error _get_sim_iccid, cannot get ports'
    # usb_ctl: ['/dev/ttyUSB3', '/dev/ttyUSB2', '/dev/ttyUSB1', '/dev/ttyUSB0']
    # get the last port, it is usually control one
    usb_ctl = ls[1]

    ans = None
    sp = None
    try:
        sp = serial.Serial(usb_ctl, baudrate=115200,
            timeout=1, rtscts=True, dsrdtr=True
        )
        sp.flushInput()
        sp.readall()

        # query hat about GPS output stream
        sp.write(b"AT+QCCID\r")
        time.sleep(.1)
        ans = sp.readall()
    except (Exception, ) as ex:
        print(f'error _get_sim_iccid -> {ex}')
    finally:
        if sp:
            sp.close()

    if type(ans) is bytes:
        return ans.decode()
    return 'error _get_sim_iccid, ans weird value'


def _get_cred():
    # hardcoded, this user cannot do anything else
    _k = 'AKIA2SU3QQX6RGB6ULQE'
    _s = 'ytpnMk04k7jmV6MoKemP+OZyt2kBiloS6r6WKM9f'
    return _k, _s


def gor_send_email_cannot_mount():

    # we can mount, we are OK
    c = 'ls /li'
    rv = sp.run(c, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    if rv.returncode == 0:
        # all OK
        print('/li mounted OK')
        return

    sim_id = _get_sim_iccid()
    print(f'sim ID value = {sim_id}')
    # key ID and secret
    _k, _s = _get_cred()

    # prepare the SNS notification about cannot mount LI point
    s = f'error mount LI point - DDH SIM ICCID: {sim_id}'

    cli = boto3.client(
        "sns",
        aws_access_key_id=_k,
        aws_secret_access_key=_s,
        region_name="us-east-2"
    )

    # test
    rsp = cli.publish(
        TopicArn='arn:aws:sns:us-east-2:727249356285:top_ddh_sys',
        Message=s,
        Subject='DDH: error cannot mount /li'
    )

    # detect errors
    if rsp['ResponseMetadata']['HTTPStatusCode'] != 200:
        print(f'error: gor_send_email_cannot_mount() -> {rsp}')
        return

    print('SNS error message telling us we could not mount -> published OK')


if __name__ == '__main__':
    gor_send_email_cannot_mount()
    # _rv = _get_sim_iccid()
    # print(_rv)
