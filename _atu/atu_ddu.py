#!/usr/bin/env python3



from _atu_cmd import cmd



if __name__ == '__main__':
    timeout = 30
    cmd('ddu', '/home/pi/li/ddt/pop_ddh.sh', timeout)
