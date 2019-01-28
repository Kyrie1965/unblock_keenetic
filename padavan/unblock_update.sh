#!/bin/sh

ipset flush unblock

/opt/bin/unblock_dnsmasq.sh
restart_dhcpd
sleep 3
/opt/bin/unblock_ipset.sh &