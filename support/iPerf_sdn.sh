#!/bin/bash
# start-up script for the whole unifycore topology (both forwarders and controllers)


if [[ $EUID -ne 0 ]]; then
    echo 'Dont forget to use sudo ;-)'
    exit 1
fi

FWD_ROOT="/home/unifycore/ofsoftswitch13"
CNT_SCRIPT="/home/unifycore/ryu/ryu/app/iPerf_magic.py"
#CNT_SCRIPT="/root/ryu/ryu/app/hub.py"

CONTROLLER="tcp:127.0.0.1:6633"

#VALGRIND="valgrind --suppressions=/root/valgrind.suppress --leak-check=yes "
VALGRIND="valgrind --log-file=/tmp/valgrind.log --tool=memcheck --leak-check=yes "

function start_fwd() {
	SOCKET="unix:/tmp/dp$1.socket"
	$FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v > /tmp/dp$1.log 2>&1 &
	$FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of$1.log 2>&1 &
}

function debug_fwd() {
	SOCKET="unix:/tmp/dp$1.socket"
	$FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of$1.log 2>&1 &
	gdb --args $FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v 
}

function valgrind_fwd() {
	SOCKET="unix:/tmp/dp$1.socket"
	$FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of$1.log 2>&1 &
	$VALGRIND $FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v 
}

function start_cnt() {
	#screen -d -m -S "controller" ryu-manager $CNT_SCRIPT --observe-links --verbose > /tmp/controller.log 2>&1
	ryu-manager $CNT_SCRIPT --observe-links --verbose > /tmp/controller.log 2>&1 &
}

function do_start() {
        start_fwd a 00000000000a 'linkAFwdA,linkABFwdA'
        start_fwd b 00000000000b 'linkABFwdB,linkBCFwdB'
        start_fwd c 00000000000c 'linkBCFwdC,linkCFwdC'       

        #sleep 0.5

	start_cnt
	sleep 0.5
        # added due to Ubuntu 14.04 network manager problem
        #ifconfig linkAOut 1.1.1.1/24
        #ifconfig linkCOut 2.2.2.2/24
        #service network-manager restart


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

