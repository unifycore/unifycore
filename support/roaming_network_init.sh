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

#uncomment this for single-core Unifycore deployment 
#ip link add vgsn0 type veth peer name corea2
#ip link add internet0 type veth peer name corec3
#ip link add corea3 type veth peer name coreb1
#ip link add corea4 type veth peer name cored1
#ip link add coreb2 type veth peer name cored2
#ip link add corec1 type veth peer name coreb3
#ip link add corec2 type veth peer name coree2
#ip link add cored3 type veth peer name coree1

#comment this for single-core Unifycore deployment
#core 1
ip link add vgsn1 type veth peer name core1a2
ip link add core1a3 type veth peer name core1b1
ip link add core1a4 type veth peer name core1d1
ip link add core1b2 type veth peer name core1d2
ip link add core1c1 type veth peer name core1b3
ip link add core1c2 type veth peer name core1e2
ip link add core1d3 type veth peer name core1e1

#core 2
ip link add vgsn2 type veth peer name core2a2
ip link add core2a3 type veth peer name core2b1
ip link add core2a4 type veth peer name core2d1
ip link add core2b2 type veth peer name core2d2
ip link add core2c1 type veth peer name core2b3
ip link add core2c2 type veth peer name core2e2
ip link add core2d3 type veth peer name core2e1

#core interconnect for data and signaling
ip link add core1c4 type veth peer name core2c4
ip link add sig1 type veth peer name sig2

#links from cores to internet
ip link add internet1 type veth peer name core1c3
ip link add internet2 type veth peer name core2c3

#links from BSS to cores are created later (see below)

#create network namespaces to separate the network cores
ip netns add 23101
ip netns add 90170

#add core links to separate namespaces
#core1
ip link set vgsn1 netns 23101
ip link set core1a2 netns 23101
ip link set core1a3 netns 23101
ip link set core1a4 netns 23101
ip link set core1b1 netns 23101
ip link set core1b2 netns 23101
ip link set core1b3 netns 23101
ip link set core1c1 netns 23101
ip link set core1c2 netns 23101
ip link set core1c3 netns 23101
ip link set core1c4 netns 23101
ip link set core1d1 netns 23101
ip link set core1d2 netns 23101
ip link set core1d3 netns 23101
ip link set core1e1 netns 23101
ip link set core1e2 netns 23101
ip link set sig1 netns 23101
#core2
ip link set vgsn2 netns 90170
ip link set core2a2 netns 90170
ip link set core2a3 netns 90170
ip link set core2a4 netns 90170
ip link set core2b1 netns 90170
ip link set core2b2 netns 90170
ip link set core2b3 netns 90170
ip link set core2c1 netns 90170
ip link set core2c2 netns 90170
ip link set core2c3 netns 90170
ip link set core2c4 netns 90170
ip link set core2d1 netns 90170
ip link set core2d2 netns 90170
ip link set core2d3 netns 90170
ip link set core2e1 netns 90170
ip link set core2e2 netns 90170
ip link set sig2 netns 90170

#configure signaling interfaces with IP addresses 
ip netns exec 23101 ifconfig sig1 192.168.27.1/24 up
ip netns exec 90170 ifconfig sig2 192.168.28.1/24 up

#add IP routes to reach the MS subscriber subnet from the linux VM for return traffic from the Internet
ip route add 172.20.85.0/24 dev internet1
ip route add 172.21.85.0/24 dev internet2


#add IP routes to allow signaling communication between the namespaces
ip netns exec 23101 ip route add 192.168.28.0/24 dev sig1
ip netns exec 90170 ip route add 192.168.27.0/24 dev sig2

#configure loopback interfaces for communication within the namespaces (vGSN <-> controller) 
ip netns exec 23101 ifconfig lo 127.0.0.1/8 up
ip netns exec 90170 ifconfig lo 127.0.0.1/8 up

#configure vGSNs with IP addresses and disable 
ip netns exec 23101 ifconfig vgsn1 192.168.27.2/24 up
ip netns exec 90170 ifconfig vgsn2 192.168.28.2/24 up

#disable checksum offloading due to kernel bug on veth interfaces
ip netns exec 23101 ethtool --offload vgsn1 rx off tx off
ip netns exec 90170 ethtool --offload vgsn2 rx off tx off

#configure IP addresses on internet interfaces
ifconfig internet1 172.20.255.254/16 up
ifconfig internet2 172.21.255.254/16 up

#uncomment these line for single-core Unifycore deployment
#ifconfig vgsn0 192.168.27.2/24
#ifconfig vgsn0 up
#ifconfig internet0 172.20.255.254/16
#ifconfig internet0 up
#ethtool --offload vgsn0 rx off tx off

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
service dnsmasq restart

tcpreplayInterfaces=( bss0 corea1  )
btsInterfaces=(eth2)
commonInterfaces=( vgsn0 internet0 corea3 corea4 coreb2 corec1 corec2 cored3 corea2 corea3 coreb1 cored1 cored2 coreb3 coree2 coree1 )

# When UnifyCore is being run with tcpDump, one link needs to be added (this is used instead of eth2)
if [ "$topologySetup" == "tcpreplay" ]; then
   #uncomment this in single-core unifycore deployment
   #ip link add bss0 type veth peer name corea1
   #create interfaces between BSS simulator and both network cores
   ip link add bss1 type veth peer name core1a1
   ip link add bss2 type veth peer name core2a1
   #add interfaces to separate namespaces
   ip link set core1a1 netns 23101
   ip link set core2a1 netns 90170
   #add IP addresses to BSS interfaces to reach vGSNs in different subnets
   ifconfig bss1 192.168.25.1/24 up
   ifconfig bss2 192.168.26.1/24 up
   
   #add IP routes to reach core networks (BSS <-> vGSN communication)
   ip route add 192.168.27.0/24 dev bss1
   ip route add 192.168.28.0/24 dev bss2


#   echo "**** Configuring tcpreplay setup ****"
#   interfaces=( "${tcpreplayInterfaces[@]}" "${commonInterfaces[@]}" )
#else
#   echo "**** Configuring BTS setup ****"
#   interfaces=( "${btsInterfaces[@]}" "${commonInterfaces[@]}" )
fi

#maybe not necessary
#echo ${interfaces[@]}
#for INT in ${interfaces[@]}; do
#	ip link set $INT mtu 1500
#done
#ip link set eth2 mtu 1600
#XXX: toto mozno nie je treba?
#ip link set internet0 mtu 1200
