#!/bin/sh

if [ "$1" == "remove" ]
then
  opkg remove mc tor tor-geoip bind-dig cron dnscrypt-proxy2
  rm -rf /opt/etc/tor/torrc
  rm -rf /opt/etc/unblock.txt
  rm -rf /opt/etc/unblock.dnsmasq
  rm -rf /opt/bin/unblock_ipset.sh
  rm -rf /opt/bin/unblock_dnsmasq.sh
  rm -rf /opt/bin/unblock_update.sh
  rm -rf /opt/etc/init.d/S99unblock
  rm -rf /opt/etc/crontab
  rm -rf /opt/etc/dnscrypt-proxy.toml
  
  sed -i '/modprobe ip_set/d' /etc/storage/start_script.sh
  sed -i '/modprobe xt_set/d' /etc/storage/start_script.sh
  sed -i '/ipset create unblock hash:net/d' /etc/storage/start_script.sh
  
  sed -i '/unblock/d' /etc/storage/post_iptables_script.sh
  sed -i '/dport 53/d' /etc/storage/post_iptables_script.sh
  
  sed -i '/unblock.dnsmasq/d' /etc/storage/dnsmasq/dnsmasq.conf
  sed -i '/server=8.8.8.8/d' /etc/storage/dnsmasq/dnsmasq.conf
  
  reboot
  
  exit 0
fi

if [ "$1" == "dnscrypt" ]
then
  if [ ! -f /opt/etc/init.d/S99unblock ]; then
    echo "Ошибка! Основной метод обхода блокировок не реализован в системе. Запустите unblock_keenetic/padavan.sh без параметров."
    exit 0
  fi
  
  opkg update
  opkg install dnscrypt-proxy2
  
  rm -rf /opt/etc/dnscrypt-proxy.toml
  wget --no-check-certificate -O /opt/etc/dnscrypt-proxy.toml https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/dnscrypt-proxy.toml
  
  /opt/etc/init.d/S09dnscrypt-proxy2 start
  
  rm -rf /opt/bin/unblock_ipset.sh
  wget --no-check-certificate -O /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/unblock_ipset_dnscrypt.sh
  chmod +x /opt/bin/unblock_ipset.sh
  
  rm -rf /opt/bin/unblock_dnsmasq.sh
  wget --no-check-certificate -O /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/unblock_dnsmasq_dnscrypt.sh
  chmod +x /opt/bin/unblock_dnsmasq.sh
  
  unblock_update.sh
  
  exit 0
fi

rm -rf /opt/etc/tor/torrc
rm -rf /opt/etc/unblock.txt
rm -rf /opt/etc/unblock.dnsmasq
rm -rf /opt/bin/unblock_ipset.sh
rm -rf /opt/bin/unblock_dnsmasq.sh
rm -rf /opt/bin/unblock_update.sh
rm -rf /opt/etc/init.d/S99unblock
rm -rf /opt/etc/crontab
rm -rf /opt/etc/dnscrypt-proxy.toml

sed -i '/modprobe ip_set/d' /etc/storage/start_script.sh
sed -i '/modprobe xt_set/d' /etc/storage/start_script.sh
sed -i '/ipset create unblock hash:net/d' /etc/storage/start_script.sh

sed -i '/unblock/d' /etc/storage/post_iptables_script.sh
sed -i '/dport 53/d' /etc/storage/post_iptables_script.sh

sed -i '/unblock.dnsmasq/d' /etc/storage/dnsmasq/dnsmasq.conf
sed -i '/server=8.8.8.8/d' /etc/storage/dnsmasq/dnsmasq.conf

opkg update
opkg install mc tor tor-geoip bind-dig cron 

lanip=$(nvram get lan_ipaddr)

echo "" >> /etc/storage/start_script.sh
echo "modprobe ip_set" >> /etc/storage/start_script.sh
echo "modprobe ip_set_hash_ip" >> /etc/storage/start_script.sh
echo "modprobe ip_set_hash_net" >> /etc/storage/start_script.sh
echo "modprobe ip_set_bitmap_ip" >> /etc/storage/start_script.sh
echo "modprobe ip_set_list_set" >> /etc/storage/start_script.sh
echo "modprobe xt_set" >> /etc/storage/start_script.sh
echo "ipset create unblock hash:net" >> /etc/storage/start_script.sh

rm -rf /opt/etc/tor/torrc
wget --no-check-certificate -O /opt/etc/tor/torrc https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/torrc
sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/tor/torrc

wget --no-check-certificate -O /opt/etc/unblock.txt https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/unblock.txt

wget --no-check-certificate -O /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/unblock_ipset.sh
chmod +x /opt/bin/unblock_ipset.sh

wget --no-check-certificate -O /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/unblock_dnsmasq.sh
chmod +x /opt/bin/unblock_dnsmasq.sh
unblock_dnsmasq.sh

wget --no-check-certificate -O /opt/bin/unblock_update.sh https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/unblock_update.sh
chmod +x /opt/bin/unblock_update.sh

wget --no-check-certificate -O /opt/etc/init.d/S99unblock https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/S99unblock
chmod +x /opt/etc/init.d/S99unblock

echo "" >> /etc/storage/post_iptables_script.sh
echo "iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblock dst -j REDIRECT --to-port 9141" >> /etc/storage/post_iptables_script.sh
echo "iptables -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to $lanip" >> /etc/storage/post_iptables_script.sh
echo "iptables -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to $lanip" >> /etc/storage/post_iptables_script.sh

echo "" >> /etc/storage/dnsmasq/dnsmasq.conf
echo "conf-file=/opt/etc/unblock.dnsmasq" >> /etc/storage/dnsmasq/dnsmasq.conf
echo "server=8.8.8.8" >> /etc/storage/dnsmasq/dnsmasq.conf

rm -rf /opt/etc/crontab
wget --no-check-certificate -O /opt/etc/crontab https://raw.githubusercontent.com/Kyrie1965/unblock_keenetic/master/padavan/crontab

reboot