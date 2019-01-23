#!/bin/sh

ipset flush unblock

/opt/bin/unblock_dnsmasq.sh
restart_dhcpd
/opt/bin/unblock_ipset.sh &