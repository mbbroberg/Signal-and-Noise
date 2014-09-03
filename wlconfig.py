#!/usr/bin/python
############## wlconfig.py #################
# Description: Mount necessary drive & download scripts
#
# Authored by Dan Perkins (@DanielRPerkins)
# Posted by Matt Brender (@mjbrender)
#
# Scan the subdomain and consider them all workloads
# Setup script for demo workload


import os
import sys
import socket
import optparse
import subprocess

# Option parsing
parser = optparse.OptionParser()
parser.add_option('-s', '--scan-only', action = 'store_true',
                  dest = 'scan_only', default = False,
                  help = 'Only scan for new neighbors and update the hosts list')

try:
    (opts, args) = parser.parse_args()
except SystemExit, exc:
    if exc.args[0] != 0:
        sys.stderr.write(parser.format_option_help())
    raise

# Install prereqs or pass if file not found
try:
    if opts.scan_only:
        pass
    else:
        print "### Installing prerequisites"
        cpath = os.path.dirname(os.path.realpath(__file__))
        subprocess.check_output(cpath + '/prereqs.sh', stderr=subprocess.STDOUT, shell=True)
except:
    print "prereqs.sh not available in current directory, passing..."

# Import installed libs
import envoy

# Scan the local network for neighbors
print "### Scanning the network"
r = envoy.run('sudo arp-scan --interface=eth0 -lqN', timeout=10)

# Filter to get just ip addresses
print "### Checking ip addresses"
ip_list = []
for l in r.std_out.split():
    if '10.2.4.' in l and l != '10.2.4.1':
        try:
            socket.inet_aton(l)
            ip_list.append(l)
            print "Found ip '%s'" % l
        except socket.error:
            pass
if len(ip_list) < 1:
    print "Warning: Did not find any neighbors or neighbors did not respond"
cat /et
# Get the local address and add it to the list
# Note, we use socket in order to deal with the DHCP case
ip_local = ([(s.connect(('8.8.8.8', 80)),
              s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET,
              socket.SOCK_DGRAM)]][0][1])
print "Found local ip '%s'" % ip_local
ip_list.append(ip_local)

# Sort the list then put top 1/3 in group A, remainder in group B
# UPDATE: Split the groups evenly
print "### Sorting workload groups"
ip_list.sort()
i = len(ip_list)
#ip_group_a = ip_list[0:(i/3)]
ip_group_a = ip_list[0:(i/2)]
#ip_group_b = [x for x in ip_list if x not in ip_group_a]
ip_group_b = [x for x in ip_list if x not in ip_group_a]

# Write out a temp hosts file with groups
print "### Writing temp file"
with open('/tmp/hosts', 'a') as f:
    f.write('[wl-group-1]\n')
    for ip in ip_group_a:
        f.write("%s\n" % ip)
    f.write('\n[wl-group-1:vars]\nworkload=low\n')
    f.write('\n[wl-group-2]\n')
    for ip in ip_group_b:
        f.write("%s\n" % ip)
    f.write('\n[wl-group-2:vars]\nworkload=high\n')

# Replace Ansible hosts file with temp file, check for error
print "### Copy file to production"
r = envoy.run('sudo mv /tmp/hosts /etc/ansible/hosts', timeout=10)
if r.status_code == 0:
    if opts.scan_only:
        sys.exit(0)
    else:
        pass
else:
    raise Exception("Error: Status code is '%s'" % r.status_code)

# Write out crontab based on workload selection
if ip_local in ip_group_a:
    print "### Setting localhost for low-cache workload"
    wl = "uncacheable"
elif ip_local in ip_group_b:
    print "### Setting localhost for high-cache worklaod"
    wl = "cacheable"
else:
    raise Exception("Error: Did not find local IP in any group")
r = envoy.run('sudo echo "@reboot /home/user/start-%s.bash" | crontab -' % wl)
if r.status_code != 0:
    raise Exception("Failed to set crontab: %s" % r.std_err)

