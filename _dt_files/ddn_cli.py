import os

from getmac import get_mac_address
import requests


EP = 'conf_provider'
DDN_PORT_API = 9000
DDN_IP = 'ddn.lowellinstruments.com'


def _get_filename_from_content_disposition_header(cd):
    # src: codementor, downloading-files-from-urls-in-python-77q3bs0un
    if not cd:
        return None
    # cd: attachment; filename*=utf-8''config_f4%3A7b....toml
    return cd.split('\'\'')[1]


def main():
    mac = get_mac_address(interface="wlan0")
    if not mac:
        print('error: client not running, no interface wlan0')
        return
    url = f'http://{DDN_IP}:{DDN_PORT_API}/{EP}/{mac}'
    try:
        rsp = requests.get(url, timeout=5)
        rsp.raise_for_status()
    except (Exception, ) as ex:
        print(f'error: {ex}')
    else:
        if rsp and rsp.status_code == 200:
            h = rsp.headers.get('content-disposition')
            fn = _get_filename_from_content_disposition_header(h)
            print(os.getcwd())
            with open(fn, 'wb') as f:
                f.write(rsp.content)
            print(f'ddn_cli: received file {fn}')
        else:
            print(f'ddn_cli: error, nope received file')


if __name__ == "__main__":
    main()
