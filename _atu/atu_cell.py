#!/usr/bin/env python3



from _atu_cmd import build_ssh_including_command



if __name__ == '__main__':
    timeout = 5
    c = 'echo -ne \'AT+CVERSION\\r\' > /dev/ttyUSB2 && cat -v /dev/ttyUSB2 | grep 202'
    build_ssh_including_command('cell_version', c, timeout)
