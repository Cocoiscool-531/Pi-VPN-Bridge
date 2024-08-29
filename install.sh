echo "This script will ask you many questions about your setup. If you don't know what to enter,
use the example."

read -p "Enter the interface that will be used as the access point. ex. wlan0: " ap_interface
read -p "Enter the interface that will be used to connect to the wifi network ex. wlan1: " wi_interface
read -p "Enter static IP address to set in CIDR notation: " static_ip
read -p "Enter IP Address start range. ex. 192.168.86.4.2: " ip_start_range
read -p "Enter IP Address end range. ex. 192.168.86.4.20: " ip_end_range
read -p "Enter subnet mask. ex. 255.255.255.0: " subnet_mask
read -p "Enter DHCP Lease time in hours. ex. 24h: " dhcp_lease
read -p "Enter your wlan 2 letter country code. ex. US" wlan_country_code
read -p "Enter your new Wifi network name" ssid
read -p "Enter your new Wifi password" wifi_pass

sudo apt-get install apt-transport-https
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update -y
sudo apt-get upgrade -y 
sudo apt-get install Tailscale -y
sudo apt install hostapd -y 
sudo apt install dnsmasq -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
sudo systemctl reboot
sudo echo "interface ${ap_interface}
    static ip_address=${static_ip}
    nohook wpa_supplicant" > /etc/dhcpcd.conf
sudo echo "# Enable IPv4 routing
net.ipv4.ip_forward=1" > /etc/sysctl.d/routed-ap.conf
sudo iptables -t nat -A POSTROUTING -o ${wi_interface} -j MASQUERADE
sudo netfilter-persistent save
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo echo "interface=${ap_interface}
dhcp-range=${ip_start_range},${ip_end_range},${subnet_mask},${dhcp_lease}
domain=wlan
address=/gw.wlan/${static_ip}" > /etc/dnsmasq.conf
sudo rfkill unblock wlan

sudo echo "country_code=${wlan_country_code}
interface=${ap_interface}
ssid=${ssid}
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${wifi-pass}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf
sudo systemctl reboot
tailscale login
read -p "setup the host now, enter the host's HOSTNAME to continue AFTER setting up host. check readme for more instructions." hostname
tailscale up --exit-node ${hostname}
echo "Setup complete, test out your pi now and see if it works!"