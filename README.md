# Pi-VPN-Bridge
***This repo covers my project of running a Raspberry Pi 4 Model B (Which will be refered to as "pi" from now on) as a network router, that will connect through tailscale vpn.***

# Sources
[Vaibhavji Medium](https://vaibhavji.medium.com/turn-your-raspberrypi-into-a-wifi-router-5ade510601de)

[nmcli Documentation](https://networkmanager.dev/docs/api/latest/nmcli.html)

[Tailscale Documentation](https://tailscale.com/kb/1017/install)

# What you'll need
Raspberry Pi (Any type should work, i will be using a Raspberry Pi 4 Model B for this)
Another device running Tailscale on a different network, to act as an exit node. I'll call this the "host"
Compatable Network Adapter
MicroSD Card with Raspberry Pi OS Lite
*Optional*
SSH Access
Heat sink
3D Printed Case

# Getting Started
With Pi OS installed, connect your wifi adapter.
Run 

```
ip link show
```

There should be 2 "wlan#" interfaces, they may be called "wlp82s#" (replace # with number, most likely 0 and 1)

# Installing Required Packages
Start by getting the apt transport https library

```
sudo apt-get install apt-transport-https
```
Then Tailscale's signing key & Repository
```
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
```

Update your Pi with

```
sudo apt-get update
sudo apt-get upgrade
```

Now install Tailscale
```
sudo apt-get install Tailscale
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
sudo iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
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
dhcp-range=192.168.4.2,192.168.4.5,255.255.255.0,24h
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

#Boot Tailscale on both your host and Pi
From the Tailscale quickstart:
"Go to [tailscale.com](https://tailscale.com) and select Get Started. Alternatively, you can [download and install](https://tailscale.com/kb/1347/installation) the Tailscale client on your device, then [sign up](https://login.tailscale.com/start).

On the Sign up with your identity provider page, log in using a single sign-on (SSO) identity provider account."

On the CLI (used on most Linux devices and Pi) type this
```
tailscale login
```
You should be prompted to sign in, sign in with the account made earlier

On the app, open the app and sign in as prompted.

Then on your host device, if it is a Mac:
"From the Tailscale client, select Settings.
Locate CLI integration section, then select Show me how.
Select Install Now and provide the macOS administrator password."
If on Windows:
"On Windows, you can access the CLI by executing the .exe from the Command Prompt."
Linux can continue with no extra steps.

Now on the HOST, run
```
tailscale up --advertise-exit-node
```
note: you may want to add any of the following along with this to allow access to local web servers, set DNS settings, etc.
```
--accept-dns=[true/false]
--advertise-routes[ip address range ex. 192.168.86.0/24
--hostname [chosen_host_name]
```

Note the hostname from the [admin portal](https://login.tailscale.com/admin/machines)

Now we will set up the Pi

On the pi, with power and Pi OS, run:
```
tailscale up --exit-node [host's_hostname]
```

Now connect to the VPN and check if its working.
I would test it by trying it out on a local webserver or checking if adblocking through pihole is working.
If you advertised your network through ```--advertise-routes[ip address range ex. 192.168.86.0/24``` on the host and used ```--accept-routes``` on the pi you can try
```
ping [your router's IP address or local web server]
```
and terminate the proccess with Control C once you know if its working.




# Thats it! It should now be working.
