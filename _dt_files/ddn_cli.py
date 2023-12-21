from getmac import get_mac_address
import requests


EP = 'conf_provider'
DDN_PORT_API = 9000
DDN_IP = 'ddn.lowellinstruments.com'


def main():
    mac = get_mac_address(interface="wlan0")
    if not mac:
        print('error, no interface wlan0')
        return
    url = f'http://{DDN_IP}:{DDN_PORT_API}/{EP}/{mac}'
    try:
        rsp = requests.get(url, timeout=5)
        rsp.raise_for_status()
    except (Exception, ) as ex:
        print(f'error: {ex}')
    else:
        print('we should have received a config.toml file')


if __name__ == "__main__":
    main()
