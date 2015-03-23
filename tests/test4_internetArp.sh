#!/bin/bash

# Test 4.
# Check whether controller replies to ARP from the internet APN (external network)
# Parameters: none 

result="OK"
echo "Checking external ARP handling"
echo ""

echo ""
echo "**** Starting tcpdump on internet0 interface ****"
rm -rf /tmp/test4.pcap
tcpdump -n -i internet0 -w /tmp/test4.pcap icmp or arp > /dev/null 2>&1 &
arp -d 1.1.1.1 > /dev/null 2>&1 

echo ""
echo "**** Sending PING via internet0 interface ****"
ping -c 2 1.1.1.1 -I internet0 > /dev/null 2>&1 


echo ""
echo "**** Waiting for the end of PING ****"
sleep 4

echo ""
echo "**** Killing tcpdump ****"
killall -e tcpdump 


tcpdumpOutput=`tcpdump -tttnnr /tmp/test4.pcap 2>&1`
#echo $tcpdumpOutput


arpFound=0
icmpFound=0

if grep -q "ICMP echo request" <<< $tcpdumpOutput; then
   icmpFound=1
fi
if (grep -q "ARP, Request who-has 1.1.1.1" <<< $tcpdumpOutput) && (grep -q "ARP, Reply 1.1.1.1 is-at" <<< $tcpdumpOutput); then
   arpFound=1
fi


if [ -n $icmpFound ] && [ -n $arpFound ]; then
   echo "OK: Both ICMP echo and ARP request/response found"
else
   if  [ -n $icmpFound ] && [ -n !$arpFound ]; then
       echo "OK: MAC address was cached, ICMP found,  ARP request/response not found"
   else
      if [ -n !$icmpFound ] && [ -n $arpFound ]; then
        echo "OK: ARP request/response found, ICMP not found"
      else
        echo "ERROR: ARP nor ICMP were found in the pcap, controller is not responding to external network ARPs"
        result="NOK"
      fi
   fi
fi




echo ""
if [ $result == 'OK' ]; then
   echo "PASSED: External ARP handling check passed, controller ARP handling is correct"
else
   echo "FAILED: External ARP handling check failed, there is something wrong with the controller , please consult README or our mailing-list" 
fi

