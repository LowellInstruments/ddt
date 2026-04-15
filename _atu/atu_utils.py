


def utils_get_ssh(timeout, ip):
    c = f'timeout {timeout} '
    c += f'ssh -i $HOME/Downloads/id_key pi@{ip} '
    c += '-o StrictHostKeyChecking=accept-new '
    c += '-o PasswordAuthentication=no '
    return c
