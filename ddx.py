from fabric import Connection
import socket


def _is_this_an_ip_address(a):
    try:
        socket.inet_aton(a)
        return True
    except socket.error:
        return False


def _hostname_to_ip_address(h):
    if _is_this_an_ip_address(h):
        return h
    d = {
        # 'cubefarm': '10.5.0.12',
        'atlantic': '10.5.0.252',
    }
    return d[h]


def _cmd(ls_ns, cmd):
    # ls_ns: ls not safe
    ls = [_hostname_to_ip_address(h) for h in ls_ns]
    rv_all = list()

    for i, h in enumerate(ls):
        c = Connection(
            h, user='pi',
            # connect_kwargs={'key_filename': '/home/kaz/.ssh/id_rsa_pm'})
            connect_kwargs={"password": 'li_ddh_82!!'})

        rv = c.run(cmd, pty=True, hide='out')
        rv_all.append((ls_ns[i], rv.exited, rv.stdout, rv.stderr))

    return rv_all


def ddu(ls):
    cmd = 'cd /home/pi/li/ddt && ./pop_ddh.sh'
    return _cmd(ls, cmd)


def test(ls):
    cmd = 'uname -r'
    return _cmd(ls, cmd)


def main():
    hosts_to_send_cmd = [
        'atlantic'
    ]
    rv = test(hosts_to_send_cmd)
    print(rv)


if __name__ == '__main__':
    main()
