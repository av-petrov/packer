#!/bin/bash

apt-get install wireguard -y
tar xzvf /tmp/wg.tgz -C /
rm -f /tmp/wg.tgz
chown -R root:root /etc/wireguard
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wg.conf 
systemctl enable wg-quick@wg0.service
apt-get clean
> /var/log/syslog
> /var/log/cloud-init.log