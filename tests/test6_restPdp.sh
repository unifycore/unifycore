#!/bin/bash

# Test 6.
# Check the Rest interface for creation of PDPs
# Parameters: optional URI parameters, if none is provided, defaults will be used



result="OK"
echo "Checking REST based creation of PDP contexts (simulation of vGSN)"
echo ""

echo ""
echo "**** Calling the controller REST URI ****"
jsonOutput=`curl -s -X GET "127.0.0.1:8080/gprs/pdp/cmd=add&rai=901-70-1-0&apn=internet&bvci=2&tlli=0xc5a4aeea&sapi=3&nsapi=5&drx_param=1027&imsi=231014450469959"`
#echo $jsonOutput


echo ""
echo "**** Parsing JSON data  ****"
elementsCount=`jq '.|length' <<< $jsonOutput 2>&1`

if grep -q "Tunnel not found" <<< $jsonOutput; then
   echo "ERROR: REST response contains error message, tunnel was not created"
   result="NOK"
else
   echo "OK: No error message was found in the response"
fi

if [ "$result" == "OK" ]; then
   if [ $elementsCount -eq 3 ]; then
      echo "OK: REST response has correct number of elements "
   else
      echo "ERROR: REST response has incorrect number of elements."
      result="NOK"
   fi
fi




echo ""
if [ $result == 'OK' ]; then
   echo "PASSED: PDP Context created, SDN core and REST interface fully operational"
else
   echo "FAILED: PDP Context creation failed, no tunnel suitable for requested PDP was found. Check all edge interfaces for an IP address or consult README or our mailing-list" 
fi


