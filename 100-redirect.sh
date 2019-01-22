#!/bin/sh

[ "$type" == "ip6tables" ] && exit 0

if [ -z "$(iptables-save 2>/dev/null | grep unblock)" ]; then
    iptables -w -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblock dst -j REDIRECT --to-port 9141
fi

if [ -z "$(iptables-save 2>/dev/null | grep "udp \-\-dport 53 \-j DNAT")" ]; then
    iptables -w -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to 192.168.1.1
fi

if [ -z "$(iptables-save 2>/dev/null | grep "tcp \-\-dport 53 \-j DNAT")" ]; then
    iptables -w -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
fi

exit 0