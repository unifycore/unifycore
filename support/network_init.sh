#!/bin/bash

#
# Network topology initiation script
# If no parameters is given, topology is configured for BTS setup (use of eth2)
# If any parameter is given, extra interface towards tcpreplay (simulation BTS is configures)


topologySetup="bts"
if [ $# -eq 0 ]; then
   topologySetup="bts"
else
   topologySetup="tcpreplay"
fi
  
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


tcpreplayInterfaces=( bss0 corea1  )
btsInterfaces=(eth2)
commonInterfaces=( vgsn0 internet0 corea3 corea4 coreb2 corec1 corec2 cored3 corea2 corea3 coreb1 cored1 cored2 coreb3 coree2 coree1 )

# When UnifyCore is being run with tcpDump, one link needs to be added (this is used instead of eth2)
if [ "$topologySetup" == "tcpreplay" ]; then
   ip link add bss0 type veth peer name corea1
   echo "**** Configuring tcpreplay setup ****"
   interfaces=( "${tcpreplayInterfaces[@]}" "${commonInterfaces[@]}" )
else
   echo "**** Configuring BTS setup ****"
   interfaces=( "${btsInterfaces[@]}" "${commonInterfaces[@]}" )
fi

#echo ${interfaces[@]}
for INT in ${interfaces[@]}; do
	ip link set $INT mtu 1500
done
ip link set eth2 mtu 1600
#XXX: toto mozno nie je treba?
ip link set internet0 mtu 1200
