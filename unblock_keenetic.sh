#!/bin/sh

if [ "$1" == "remove" ]
then
  opkg remove mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables dnscrypt-proxy2
  rm -rf /opt/etc/ndm/fs.d/100-ipset.sh
  rm -rf /opt/etc/tor/torrc
  rm -rf /opt/etc/unblock.txt
  rm -rf /opt/etc/unblock.dnsmasq
  rm -rf /opt/bin/unblock_ipset.sh
  rm -rf /opt/bin/unblock_dnsmasq.sh
  rm -rf /opt/bin/unblock_update.sh
  rm -rf /opt/etc/init.d/S99unblock
  rm -rf /opt/etc/ndm/netfilter.d/100-redirect.sh
  rm -rf /opt/etc/dnsmasq.conf
  rm -rf /opt/etc/crontab
  rm -rf /opt/etc/dnscrypt-proxy.toml
  
  ndmq -p 'no opkg dns-override'
  ndmq -p 'system configuration save'
  ndmq -p 'system reboot'
  
  sleep 5
  
  exit 0
fi

if [ "$1" == "dnscrypt" ]
then
  if [ ! -f /opt/etc/init.d/S99unblock ]; then
    echo "Ошибка! Основной метод обхода блокировок не реализован в системе. Запустите unblock_keenetic.sh без параметров."
    exit 0
  fi
  
  opkg install dnscrypt-proxy2
  
  rm -rf /opt/etc/dnscrypt-proxy.toml
  wget --no-check-certificate -O /opt/etc/dnscrypt-proxy.toml https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/dnscrypt-proxy.toml
  
  /opt/etc/init.d/S09dnscrypt-proxy2 start
  
  rm -rf /opt/bin/unblock_ipset.sh
  wget --no-check-certificate -O /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/unblock_ipset_dnscrypt.sh
  chmod +x /opt/bin/unblock_ipset.sh
  
  rm -rf /opt/bin/unblock_dnsmasq.sh
  wget --no-check-certificate -O /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/unblock_dnsmasq_dnscrypt.sh
  chmod +x /opt/bin/unblock_dnsmasq.sh
  
  unblock_update.sh
  
  exit 0
fi

rm -rf /opt/etc/ndm/fs.d/100-ipset.sh
rm -rf /opt/etc/tor/torrc
rm -rf /opt/etc/unblock.txt
rm -rf /opt/etc/unblock.dnsmasq
rm -rf /opt/bin/unblock_ipset.sh
rm -rf /opt/bin/unblock_dnsmasq.sh
rm -rf /opt/bin/unblock_update.sh
rm -rf /opt/etc/init.d/S99unblock
rm -rf /opt/etc/ndm/netfilter.d/100-redirect.sh
rm -rf /opt/etc/dnsmasq.conf
rm -rf /opt/etc/crontab
rm -rf /opt/etc/dnscrypt-proxy.toml
  
opkg update
opkg install mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables 

set_type = "hash:net"

ipset create testset hash:net -exist > /dev/null 2>&1
retVal=$?
if [ $retVal -ne 0 ]; then
  set_type = "hash:ip"
fi

lanip=$(ndmq -p 'show interface Bridge0' -P address)

wget --no-check-certificate -O /opt/etc/ndm/fs.d/100-ipset.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/100-ipset.sh
chmod +x /opt/etc/ndm/fs.d/100-ipset.sh
sed -i "s/hash:net/${set_type}/g" /opt/etc/ndm/fs.d/100-ipset.sh

rm -rf /opt/etc/tor/torrc
wget --no-check-certificate -O /opt/etc/tor/torrc https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/torrc
sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/tor/torrc

wget --no-check-certificate -O /opt/etc/unblock.txt https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/unblock.txt

wget --no-check-certificate -O /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/unblock_ipset.sh
chmod +x /opt/bin/unblock_ipset.sh

wget --no-check-certificate -O /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/unblock_dnsmasq.sh
chmod +x /opt/bin/unblock_dnsmasq.sh
unblock_dnsmasq.sh

wget --no-check-certificate -O /opt/bin/unblock_update.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/unblock_update.sh
chmod +x /opt/bin/unblock_update.sh

wget --no-check-certificate -O /opt/etc/init.d/S99unblock https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/S99unblock
chmod +x /opt/etc/init.d/S99unblock
sed -i "s/hash:net/${set_type}/g" /opt/etc/init.d/S99unblock
sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/init.d/S99unblock

wget --no-check-certificate -O /opt/etc/ndm/netfilter.d/100-redirect.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/100-redirect.sh
chmod +x /opt/etc/ndm/netfilter.d/100-redirect.sh
sed -i "s/hash:net/${set_type}/g" /opt/etc/ndm/netfilter.d/100-redirect.sh
sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/ndm/netfilter.d/100-redirect.sh

rm -rf /opt/etc/dnsmasq.conf
wget --no-check-certificate -O /opt/etc/dnsmasq.conf https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/dnsmasq.conf
sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/dnsmasq.conf

rm -rf /opt/etc/crontab
wget --no-check-certificate -O /opt/etc/crontab https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/crontab

ndmq -p 'opkg dns-override'
ndmq -p 'system configuration save'
ndmq -p 'system reboot'