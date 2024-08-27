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
```ip link show```
There should be 2 "wlan#" interfaces, they may be called "wlp82s#" (replace # with number, most likely 0 and 1)

# Setting Up Access Point
Update your Pi with
```sudo apt-get update```
```sudo apt-get upgrade```

reboot to ensure instalation
```sudo reboot```
