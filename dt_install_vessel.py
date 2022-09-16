#!/usr/bin/env python3

import pycurl
import subprocess as sp
from io import BytesIO
import os
import pathlib
import sys


URL = ''
_PF_TMP = '/tmp/tmp.zip'
_LI = pathlib.Path('/home/pi/li/')
_PDD = pathlib.Path(_LI / 'ddh')
_PDV = pathlib.Path(_LI / 'ddh_tools/_vessel_files')


def _banner_usage():
    print('\nusage: ./dt_install_vessel.py WS_URL vessel_name.zip\n')
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print('error: bad number of parameters')
        sys.exit(1)

    # URL example: http://3.14.66.209:2341/
    global URL
    URL = sys.argv[1]
    if not URL.endswith('/'):
        URL += '/'


def _banner_success():
    print('done!')


def _sh(s):
    rv = sp.run(s, shell=True, stdout=sp.PIPE, stderr=sp.PIPE)
    return rv.returncode


def _end_if(cond, e=''):
    e = e if e else '[ error ]'
    if cond:
        print('\t' + e)
        exit(1)


def _perform_curl_by_url(url: str) -> bytes:
    buf_io = BytesIO()
    c = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, buf_io)
    c.setopt(c.TIMEOUT, 5)
    c.perform()
    c.close()
    return buf_io.getvalue()


def _list_all_vessel_zip_files_from_ddh_ws():
    s = 'listing vessels from Lowell web service at url {}'
    print(s.format(URL))
    a = _perform_curl_by_url(URL)
    a = [i for i in a.split(b'$') if i]
    for i in a:
        print('\t{}'.format(i))
    print('\n')

    # nothing more to do
    if len(sys.argv) == 2:
        sys.exit(0)


def _get_vessel_zip_file_from_ddh_ws(v):
    print('requesting vessel file {} from web service'.format(v))
    url = URL + 'files/get?ddh=' + v
    a = _perform_curl_by_url(url)
    # PK means zip file mime type
    _end_if(a[:2] != b'PK')
    return a


def _save_vessel_zip_file_to_disk(data: bytes):
    print('saving vessel zip file to disk')
    if os.path.exists(_PF_TMP):
        os.remove(_PF_TMP)
    file = open(_PF_TMP, 'wb')
    rv = file.write(data)
    file.close()
    _end_if(len(data) != rv)


def _unzip_vessel_zip_file():
    # fails if not pycharm: emulate terminal on output console
    print('unzipping zip file -> password:')
    s = 'unzip -o {}'.format(_PF_TMP)
    _end_if(_sh(s))


def _check_vessel_zip_file_contents():
    print('checking contents in vessel zip file')
    j = os.path.exists(str(_PDV / 'ddh.json'))
    r = os.path.exists(str(_PDV / 'run_ddh.sh'))
    m = os.path.exists(str(_PDV / '_macs_to_sn.yml'))
    # print(j, r, m)
    _end_if(not (j and r and m))


def _detect_we_are_on_ddh():
    print('detecting we are on DDH')
    _end_if(not os.path.isdir(_PDD))


def _copy_vessel_files_to_ddh_install_folder():
    _detect_we_are_on_ddh()
    print('copying vessel files to ddh install folder')
    j = _sh('cp {}/ddh.json {}/settings'.format(_PDV, _PDD))
    r = _sh('cp {}/run_ddh.sh {}'.format(_PDV, _PDD))
    m = _sh('cp {}/_macs_to_sn.yml {}/settings'.format(_PDV, _PDD))
    # print(j, r, m)
    _end_if(j or r or m)


def _remove_any_previous_local_vessel_files_folder():
    print('removing previous vessel files local folder')
    rm = _sh('rm -rf {}'.format(str(_PDV)))
    _end_if(rm)


def main():
    _banner_usage()
    _list_all_vessel_zip_files_from_ddh_ws()
    _remove_any_previous_local_vessel_files_folder()
    b = _get_vessel_zip_file_from_ddh_ws(sys.argv[2])
    _save_vessel_zip_file_to_disk(b)
    _unzip_vessel_zip_file()
    _check_vessel_zip_file_contents()
    _copy_vessel_files_to_ddh_install_folder()
    _banner_success()


# ------------------------------
# run this script from terminal
# -------------------------------
if __name__ == '__main__':
    try:
        main()
    except pycurl.error as ce:
        print('curl error {} '.format(ce))
