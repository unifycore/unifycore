#!/bin/bash

# Test 5.
# Check all forwarders and APNs are detected by the controller (sample topology)
# Parameters: none 

result="OK"
echo "Checking if the running topology equals to the sample topology"
echo ""



echo ""
echo "**** Getting JSON from controller REST interface ****"
jsonOutput=`curl -s -X GET 127.0.0.1:8080/topology/dump`
#echo $jsonOutput


echo ""
echo "**** Parsing JSON data  ****"
nodesCount=`jq '.nodes|length' <<< $jsonOutput`
linksCount=`jq '.links|length' <<< $jsonOutput`

if [ $nodesCount -eq 7 ]; then
   echo "OK: Topology has correct number of nodes"
else
   echo "ERROR: Topology has different number of nodes than sample topology"
   result="NOK"
fi
   
if [ $linksCount -eq 16 ]; then
   echo "OK: Topology has correct number of links "
else
   echo "ERROR: Topology has different number of links than sample topology"
   result="NOK"
fi


echo ""
echo "**** Comparing node IDs ****"
jsonNodesList=` jq  '.nodes[].id' <<< $jsonOutput`
sampleNodesList=( 10 11 12 13 14 \"internet\" \"901-70-1-0\" ) # in current implementation, string named nodes contain quotation marks

for sNode in ${sampleNodesList[@]}; do
   found=0
   for jNode in ${jsonNodesList[@]}; do
       #echo "Comparing $sNode and $jNode"
       if [ "$sNode" ==  "$jNode" ]; then
         found=1
         break
       fi
   done
   if [ $found -eq 1 ]; then
     echo "OK: Node $sNode present in json (running topology)" 
   else
     echo "NOK: Node $sNode not present in json (running topology)"
     result="NOK"
   fi
done






echo ""
if [ $result == 'OK' ]; then
   echo "PASSED: UnifyCore sample topology is up and running"
else
   echo "FAILED: Running topology is different topology than the sample one, if you did not make any changes to the topology, please consult README or our mailing-list" 
fi


