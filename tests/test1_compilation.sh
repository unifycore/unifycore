#!/bin/bash

# Test 1.
# Check whether unifycore components are properly built and ready to use
# Parameters: one optional parameter == directory where all the components were installed

if [ $# -eq 0  ]; then
   DIR="$HOME"
else
   DIR=$1
fi

echo "Checking proper buid of Unifycore components"
echo "Looking for UnifyCore components in $DIR directory"
echo ""

nitbLocation="$DIR/openbsc/openbsc/src/osmo-nitb/osmo-nitb"
vgsnLocation="$DIR/openbsc/openbsc/src/gprs/osmo-sgsn"
cntLocation="$DIR/ryu/ryu/app/magic.py"
fwdDLocation="$DIR/ofsoftswitch13/udatapath/ofdatapath"
fwdSLocation="$DIR/ofsoftswitch13/secchan/ofprotocol"
result="OK"

if [ -e $nitbLocation ]; then
   echo "OK:    osmo-nitb binary found"
else
   echo "ERROR: osmo-nitb binary not found, call routing and sysmoBTS bootstrap will not be functional!"
   result="NOK"
fi

if [ -e $vgsnLocation ]; then
   echo "OK:    vGSN binary found"
else
   echo "ERROR: vGSN binary not found, GPRS features will not be functional!"
   result="NOK"
fi

if [ -e $cntLocation ]; then
   echo "OK:    Controller script found"
else
   echo "ERROR: Controller script not found, SDN core will not be fuctional at all!"
   result="NOK"
fi

if [ -e $fwdDLocation ]; then
   echo "OK:    Forwarder datapath binary found"
else
   echo "ERROR: Forwarder datapath binary not found, SDN core will not be functional at all!"
   result="NOK"
fi

if [ -e $fwdSLocation ]; then
   echo "OK:    Forwarder secchan binary found"
else
   echo "ERROR: Forwarder secchan binary not found, SDN core will not be functional at all!"
   result="NOK"
fi



echo ""
if [ $result == 'OK' ]; then
   echo "PASSED: UnifyCore compilation was successful"
else
   echo "FAILED: UnifyCore compulation was unsuccessful, please consult README or our mailing-list" 
fi

