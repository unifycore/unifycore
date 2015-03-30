#!/bin/bash

#Unifycore installation script - DNS addition for iPerf capacity testing
#Scripts adds two records into /etc/hosts


#add IP addresses of iPerf PCs into DNS
echo "1.1.1.1  iperfclient" >> /etc/hosts
echo "2.2.2.2  iperfserver" >> /etc/hosts

