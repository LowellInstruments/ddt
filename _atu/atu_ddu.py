#!/usr/bin/env python3



from _atu_cmd import build_ssh_including_command



if __name__ == '__main__':
    timeout = 30
    build_ssh_including_command('ddu', '/home/pi/li/ddt/pop_ddh.sh', timeout)
