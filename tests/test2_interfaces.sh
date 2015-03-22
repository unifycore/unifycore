#!/bin/bash

# Test 2.
# Check whether all interfaces needed for demo topology are up
# Parameters: none 

result="OK"
echo "Checking network interface configuration"
echo ""


interfacesNoIp=( vgsn0 internet0 corea3 corea4 coreb2 corec1 corec2 cored3 corea2 corea3 coreb1 cored1 cored2 coreb3 coree2 coree1 eth2 )
interfacesIp=( eth0 internet0 vgsn0 ) #eth1 ommited since it is used only for local telnet

echo ""
echo "**** Checking presence of interfaces ****"
for interface in ${interfacesNoIp[@]} ${interfacesIp[@]}; do
    ifconfResult=`ifconfig $interface 2>&1 | grep "Device not found"`
    #echo $ifconfig_result
    #echo ${#ifconf_result}    
    if [ ${#ifconfResult} != 0 ]; then
       echo ERROR: Interface $interface not present in system, please alter network configuration to run the deafult UnifyCore setup!
       result="NOK"
    else
       echo "OK: Interface $interface is present in system."
    fi
done

echo ""
echo "**** Checking IP configuration of interfaces ****"
for interface in ${interfacesIp[@]}; do
    ifconfResult=`ifconfig $interface 2>&1 | grep "net addr:"`
    #echo $ifconfigResult
    #echo ${#ifconfigResult}
    if [ ${#ifconfResult} == 0 ]; then
       echo ERROR: Interface $interface is missing an IP address, please alter network configuration to run the default UnifyCore setup!
       result="NOK"
    else
       echo OK: Interface $interface has an IP assigned.
    fi
done




echo ""
if [ $result == 'OK' ]; then
   echo "PASSED: UnifyCore network interfaces are correctly configured"
else
   echo "FAILED: UnifyCore network interfaces are not correctly configured, please consult README or our mailing-list" 
fi

