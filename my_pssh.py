from pssh.clients import ParallelSSHClient

# set list of hosts
# hosts = ['localhost', 'ddh_1234567.local']
hosts = ['ddh_1234567.local', ]

# create a client for all hosts
# cli = ParallelSSHClient(all_hosts)

# don't do this
cli = ParallelSSHClient(hosts, user='_____', password='_______')

# set the command to be run
all_hosts_rv = cli.run_command('uname')


def main():
    for host_rv in all_hosts_rv:
        print('{} returned: '.format(host_rv.host))
        for each_line in host_rv.stdout:
            print(each_line)
        exit_code = host_rv.exit_code


if __name__ == '__main__':
    main()


