from getmac import get_mac_address
import requests


EP_GIVE_ME_CONF = 'give_me_conf'
# DDN_IP = 'ddn.lowellinstruments.com'
DDN_IP = 'localhost'
# DDN_PORT = 7711
DDN_PORT = 8000
DDN_EP = 'conf_provider'


def main():
    mac = get_mac_address(interface="wlan0")
    if not mac:
        print('error, no interface wlan0')
        return
    url = f'http://{DDN_IP}:{DDN_PORT}/{DDN_EP}/{mac}'
    try:
        rsp = requests.get(url, timeout=5)
        rsp.raise_for_status()
    except (Exception, ) as ex:
        print(f'error: {ex}')
    else:
        print('we should have received a config.toml file')


if __name__ == "__main__":
    main()
