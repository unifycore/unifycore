#!/bin/bash
# start-up script for the whole unifycore topology (both forwarders and controllers)


if [[ $EUID -ne 0 ]]; then
    echo 'Dont forget to use sudo ;-)'
    exit 1
fi

FWD_ROOT="/home/tibor/ofsoftswitch13"
CNT_SCRIPT="/home/tibor/ryu/ryu/app/roaming_magic1.py"
#CNT_SCRIPT="/root/ryu/ryu/app/hub.py"

CONTROLLER="tcp:127.0.0.1:6633"

#VALGRIND="valgrind --suppressions=/root/valgrind.suppress --leak-check=yes "
VALGRIND="valgrind --log-file=/tmp/valgrind.log --tool=memcheck --leak-check=yes "

function start_fwd() {
	SOCKET="unix:/tmp/dp$1.socket"
	$FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v > /tmp/dp2_$1.log 2>&1 &
	$FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of2_$1.log 2>&1 &
}

function debug_fwd() {
	SOCKET="unix:/tmp/dp$1.socket"
	$FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of2_$1.log 2>&1 &
	gdb --args $FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v 
}

function valgrind_fwd() {
	SOCKET="unix:/tmp/dp$1.socket"
	$FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of2_$1.log 2>&1 &
	$VALGRIND $FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v 
}

function start_cnt() {
	#screen -d -m -S "controller" ryu-manager $CNT_SCRIPT --observe-links --verbose > /tmp/controller.log 2>&1
	ryu-manager $CNT_SCRIPT --observe-links --verbose > /tmp/controller_2.log 2>&1 &
}

function do_start() {
  # big topology from the project documentation (and README)
	#if we use a simulator, we do not use eth2, but BSS0 <---> corea1 instead
	#start_fwd a 00000000000a 'eth2,corea2,corea3,corea4'
	start_fwd a 00000000000a 'core2a1,core2a2,core2a3,core2a4'
	start_fwd b 00000000000b 'core2b1,core2b2,core2b3'
	start_fwd c 00000000000c 'core2c1,core2c2,core2c3,core2c4'
	start_fwd d 00000000000d 'core2d1,core2d2,core2d3'
	start_fwd e 00000000000e 'core2e1,core2e2'
	#sleep 0.5

	start_cnt
	sleep 0.5

	#valgrind_fwd a 00000000000a 'eth2,corea2,corea3,corea4'
	#debug_fwd a 00000000000a 'eth2,corea2,corea3,corea4'
}

function do_stop() {
	# forwarder
	killall ofprotocol
	killall ofdatapath

	# and controller
	killall ryu-manager
}

case $1 in
	start)
		do_start
		;;
	stop)
		do_stop
		;;
	restart)
		do_stop
		do_start
		;;
esac

