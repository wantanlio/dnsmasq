#!/usr/bin/bash
sudo apt update
sudo apt install -y dnsmasq bind9-dnsutils
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo echo "nameserver 127.0.0.1" | tee /etc/dns.conf
sudo echo "nameserver 169.254.169.253" | tee -a /etc/dns.conf
sudo sed -i 's,RESOLV_CONF=.*,RESOLV_CONF=/etc/dns.conf,' /etc/init.d/dnsmasq
sudo ln -s /etc/dns.conf /etc/resolv.conf -f
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bck
sudo cat <<EOF > /etc/dnsmasq.conf
bind-interfaces
bogus-priv
cache-size=500
domain-needed
neg-ttl=60
pid-file=/var/run/dnsmasq/dnsmasq.pid
port=53
resolv-file=/etc/dns.conf
group=dnsmasq
user=dnsmasq
EOF
if [ -z "/var/run/dnsmasq" ]; then
  mkdir -pv /var/run/dnsmasq
fi
sudo groupadd dnsmasq
sudo usermod -g dnsmasq dnsmasq
sudo systemctl restart dnsmasq
