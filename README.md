# Pi-VPN-Bridge
***This repo covers my project of running a Raspberry Pi Zero 2 W (Which will be refered to as "pi" from now on) as a network router, that will connect through tailscale vpn.***

# Sources
[vaibhavji Medium](https://vaibhavji.medium.com/turn-your-raspberrypi-into-a-wifi-router-5ade510601de)
[nmcli docs](https://networkmanager.dev/docs/api/latest/nmcli.html)

# What you'll need
Raspberry Pi (Any type should work, i will be using a Raspberry Pi Zero 2 W for this)
Compatable Network Adapter
MicroSD Card with Raspberry Pi OS Lite
*Optional*
SSH Access
Heatsync and Fan
3D Printed Case

# Getting Started
With Pi OS installed, connect your wifi adapter.
Run 

```
ip link show
```

There should be 2 "wlan#" interfaces, they may be called "wlp82s#" (replace # with number, most likely 0 and 1)

# Installing Required Packages
Update your Pi with

```
sudo apt-get update
sudo apt-get upgrade
```


Now install "hostapd" and "dnsmasq"
```
sudo apt install hostapd
sudo apt install dnsmasq
```
and install "netfilter-persistent" and its plugin "iptables-persistent"
```
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
```

reboot to ensure instalation

```
sudo systemctl reboot
```

# Setting Up Access Point

***We will be using "wlan0" as the input from other devices, and "wlan1" as the device connecting through the vpn, you may change this as you please***

We want to edit dhcpcd.conf to include information about "wlan0"
```
sudo nano /etc/dhcpcd.conf
```
paste in with "Control U":

```
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
```
Then press "Control X", "Y", "Enter"

Next we need to enable IP Routing and Masquerading
once again we need to edit in nano
```
sudo nano /etc/sysctl.d/routed-ap.conf
```
and paste this
```
# Enable IPv4 routing
net.ipv4.ip_forward=1
```
save same as before

Now run this to allow hosts from the network 192.168.4.0/24 to connect
```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
and save the changes
```
sudo netfilter-persistent save
```

Now we need to rename the default configuration file and edit a new one
```
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo nano /etc/dnsmasq.conf
```
Paste and save as before
```
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
domain=wlan
address=/gw.wlan/192.168.4.1
```
To ensure WiFi radio is not blocked on your Raspberry Pi, execute the following command:
```
sudo rfkill unblock wlan
```

# Configuring AP Software

create this file with nano
```
sudo nano /etc/hostapd/hostapd.conf
```
paste this in, don't save yet
```
country_code=IN
interface=wlan0
ssid=NameOfNetwork
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=PWD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```
replace "NameOfNetwork" With the networks name, "wpa_passphrase" with the password, and "country_code" with your [country code](https://en.wikipedia.org/wiki/ISO_3166-1)

reboot again
```
sudo systemctl reboot
```
Now check that the network is available on a seperate device
