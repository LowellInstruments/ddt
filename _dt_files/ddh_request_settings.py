#!/usr/bin/env python3


import sys
import time
import requests


def main():
    print(sys.argv)
    if len(sys.argv) != 3:
        print('error -> you only need vessel SN and filename')
        return 1

    # useful for testing
    time.sleep(1)
    fol, filename = sys.argv[1], sys.argv[2]
    prs = {'folder': fol, 'file': filename}
    rsp = requests.get('http://0.0.0.0:8000/ddh_conf', params=prs)

    if rsp.status_code == 200:
        # file retrieved ok
        s = 'file {} from vessel SN {} retrieved OK'
        print(s.format(filename, fol))
        sys.exit(0)

    sys.exit(1)


if __name__ == '__main__':
    main()
