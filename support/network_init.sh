#!/bin/sh
ip link add bss0 type veth peer name corea1
ip link add vgsn0 type veth peer name corea2
ip link add internet0 type veth peer name corec3
ip link add corea3 type veth peer name coreb1
ip link add corea4 type veth peer name cored1
ip link add coreb2 type veth peer name cored2
ip link add corec1 type veth peer name coreb3
ip link add corec2 type veth peer name coree2
ip link add cored3 type veth peer name coree1
