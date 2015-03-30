#!/bin/sh

#remove IP addresses of the ofsoftswitch PC interfaces
ip link add linkAOut type veth peer name linkAFwdA
ip link add linkABFwdA type veth peer name linkABFwdB
ip link add linkBCFwdB type veth peer name linkBCFwdC
ip link add linkCOut type veth peer name linkCFwdC


ifconfig linkAOut 1.1.1.1/24
ifconfig linkAOut up

ifconfig linkCOut 2.2.2.2/24
ifconfig linkCOut up

ip link set linkAOut mtu 1500
ip link set linkCOut mtu 1500

ethtool --offload linkAOut rx off tx off
ethtool --offload linkCOut rx off tx off

# added due to Ubuntu 14.04 network manager problem
service network-manager restart
