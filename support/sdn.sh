#!/bin/bash

FWD_ROOT="/root/ofsoftswitch13"
CNT_SCRIPT="/root/ryu/ryu/app/experimenter_switch.py"

CONTROLLER="tcp:127.0.0.1:6633"

function start_fwd() {
    SOCKET="unix:/tmp/dp$1.socket"
    #screen -d -m -S "dp$1" $FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" p$SOCKET -v > /tmp/dp$1.log 2>&1
    #screen -d -m -S "of$1" $FWD_ROOT/secchan/ofprotocol "$SOCK" "$CONTROLLER" --fail=closed  > /tmp/of$1.log 2>&1
    $FWD_ROOT/udatapath/ofdatapath -i "$3" -d "$2" "p$SOCKET" -v > /tmp/dp$1.log 2>&1 &
    $FWD_ROOT/secchan/ofprotocol "$SOCKET" "$CONTROLLER" --fail=closed  > /tmp/of$1.log 2>&1 &
}

function start_cnt() {
    #screen -d -m -S "controller" ryu-manager $CNT_SCRIPT --observe-links --verbose > /tmp/controller.log 2>&1
    ryu-manager $CNT_SCRIPT --observe-links --verbose > /tmp/controller.log 2>&1
}

function do_start() {
    #XXX: povodny 3-portovy test 
    start_fwd a 00000000000a "corea1,corea2,corea3"
    #XXX: velka topologia podla dokumentacie
    #start_fwd a 00000000000a "corea1,corea2,corea3,corea4"
    #start_fwd b 00000000000b "coreb1,coreb2,coreb3"
    #start_fwd c 00000000000c "corec1,corec2,corec3"
    #start_fwd d 00000000000d "cored1,cored2,cored3"
    #start_fwd e 00000000000e "coree1,coree2"

    start_cnt
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

