#!/usr/bin/env python3
import os

import time
import pexpect
import pathlib
import sys


# call this as
# sudo ./dwservice uninstall && nameofthisscript.py



PATH_FOL_HOME = pathlib.Path.home()
PATH_FIL_DWS = f'{PATH_FOL_HOME}/Downloads/dwagent.sh'



def exp_dws():

    # run parameters
    if len(sys.argv) != 2:
        print('LI -> DWS auto-install, error number of arguments')
        return
    dws_code = sys.argv[1]
    if len(dws_code) != 9 and len(dws_code) != 11:
        print('LI -> DWS auto-install, error dws_code bad length')
        return



    c = f'sudo {PATH_FIL_DWS} uninstall -console'
    child = pexpect.spawn(c)
    i = child.expect([
        'Do you want remove DWAgent?',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=1
    )
    time.sleep(.1)
    if i == 0:
        print(f'LI -> DWS auto-install, removing previous DWS')
        child.send('1\r')
        child.expect([
            'Uninstallation has completed.',
            pexpect.TIMEOUT, pexpect.EOF],
            timeout=20
        )
    child.close()




    # Raspberry is NOT gonna ask for password
    print(f'LI -> DWS auto-install, creating new agent with code {dws_code}')
    c = f'sudo {PATH_FIL_DWS} install -console'
    child = pexpect.spawn(c)



    # child.before: Contains all text printed before the matched pattern
    # child.after: Contains the exact text that matched the pattern


    # question: 1 Install 2 Run 3 decline
    i = child.expect([
        '3. Decline',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=1
    )
    time.sleep(.1)
    if i:
        child.close()
        print('LI -> DWS auto-install, error install or run')
        return
    child.send('1\r')



    # question: where to install, press 'enter' to accept default path
    i = child.expect([
        'Select the installation path:',
        'DWAgent already installed',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=1
    )
    time.sleep(.1)
    if i == 1:
        print('LI -> DWS auto-install, please uninstall agent first')
        print(child.before.decode())
        child.close(force=True)
        return
    if i:
        child.close()
        print('LI -> DWS auto-install, error install path')
        return
    child.send('\r')



    # question: ok to delete if already installed 1 Yes 2 No
    i = child.expect([
        'Do you want to install DWAgent to \'/usr/share/dwagent\'?',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=1)
    time.sleep(.1)
    if i:
        child.close()
        print(f'LI -> DWS auto-install, error confirmation\n{child.before.decode()}')
        return
    child.send('1\r')



    # the previous installing takes time, now configure 1 code 2 create new agent
    i = child.expect([
        'How would you like to configure the agent?',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=20)
    time.sleep(.1)
    if i:
        child.close()
        print(f'LI -> DWS auto-install, error doing the install\n{child.before.decode()}')
        return
    child.send('1\r')




    i = child.expect([
        'Enter the installation code',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=1)
    time.sleep(.1)
    if i:
        child.close()
        print(f'LI -> DWS auto-install, error waiting code prompt')
        return
    child.send(f'{dws_code}\r')



    i = child.expect([
        'Installation has been completed.',
        'The code entered is invalid.',
        pexpect.TIMEOUT, pexpect.EOF],
        timeout=10)
    time.sleep(.1)
    if i == 1:
        child.close()
        print('LI ->  DWS auto-install, error bad installation code')
        return


    child.close()
    print('LI -> DWS auto-install, OK')
    os._exit(0)



if __name__ == '__main__':
    exp_dws()


