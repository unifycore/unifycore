#!/bin/sh

#XXX: toto uz je eth2
#ip link add bss0 type veth peer name corea1

ip link add vgsn0 type veth peer name corea2
ip link add internet0 type veth peer name corec3
ip link add corea3 type veth peer name coreb1
ip link add corea4 type veth peer name cored1
ip link add coreb2 type veth peer name cored2
ip link add corec1 type veth peer name coreb3
ip link add corec2 type veth peer name coree2
ip link add cored3 type veth peer name coree1


ifconfig vgsn0 192.168.27.2/24
ifconfig vgsn0 up

ifconfig internet0 172.20.255.254/16
ifconfig internet0 up

ethtool --offload vgsn0 rx off tx off

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
service dnsmasq restart

for INT in bss0 vgsn0 internet0 corea3 corea4 coreb2 corec1 corec2 cored3 corea1 corea2 corea3 coreb1 cored1 cored2 coreb3 coree2 coree1 eth2; do
	ip link set $INT mtu 1500
done
ip link set eth2 mtu 1600
#XXX: toto mozno nie je treba?
ip link set internet0 mtu 1200
