#!/usr/bin/env python3



from atu_cmd import cmd



if __name__ == '__main__':
    timeout = 5
    c = 'echo -ne \'AT+CVERSION\\r\' > /dev/ttyUSB2 && cat -v /dev/ttyUSB2 | grep 202'
    cmd('cell_version', c, timeout)
