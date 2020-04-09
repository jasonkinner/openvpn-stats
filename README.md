## openvpn-stats

**A very basic bash script to parse data from OpenVPN Community server log file (typically: openvpn-status.log)**

Make sure your OpenVPN server.conf file has a line similar to the following:
status /var/log/openvpn/openvpn-status.log

Edit this script and change the 'input_file' variable to match the log file above.

To run the script,
chmod +x openvpn-stats.sh

Then, you can simply run the script as needed, eg:
...
./openvpn-stats.sh
...

Or, for constantly updated stats:
...
watch ./openvpn-stats.sh
...

Note, if you are not in the same directory as the script, you will need to reference the full path, eg:
...
/root/openvpn-stats.sh
...

or
...
watch -n 1 /root/openvpn-stats.sh
...
