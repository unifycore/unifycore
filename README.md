gprs-sdn
========
| ------------------------------------------------- |
|                                                   |
| File:   UnifyCore ReadMe and Installation guide   |
| Date:   2-19-2015                                 |
| Author: Martin Nagy                               |
|                                                   |
| ------------------------------------------------- |

UnifyCore project developed on FIIT STU (Faculty of informatics and information technologies, Slovak university of technology in Bratislava).
Credits to all projects used go to:
-Ryu SDN framework   http://osrg.github.io/ryu/
-CPqD/ofsoftswitch13 https://github.com/CPqD/ofsoftswitch13
-OpenBSC suite       http://openbsc.osmocom.org/trac/wiki/OpenBSC
-OpenGGSN            http://sourceforge.net/projects/ggsn/





Tech Leads:
****************************************
-Martin Nagy
-Ivan Kotuliak

Lead Developers: (in alphabetical order)
****************************************
-Tibor Hirjak
-Martin Kalcok
-Jan Skalny

Feature developers (work in progress)
*****************************************
-Kamil Burda (Port Control Protocol (PCP) NAT feature developement)
-Rudolf Grezo (Tunnel management and traffic engineering developement)
-Marek Hasin (LTE feature developement)
-Michal Palatinus (Observation and management GUI developement)
-Matus Krizan
-Peter Balga





INSTALLATION
-------------

Prerequisities (tested setup): 
-Oracle VirtualBox 4.3.20r96997
-Ubuntu Server 14.04 amd64 (not 14.04.1)
-Sources from the Unifycore GitHub (https://github.com/unifycore/unifycore)

Optional:
OpenBSC compliant BTS (hardware of software emulation) in order to experiment with GSM/GPRS part of the technology (we use sysmocom sysmoBTS and it is working).
WARNING: Operating your own GSM/GPRS network without permission from the local regulator or without a faraday cage may be against your local laws.

1. Install Ubuntu 14.04 (not 14.04.1), 64-bit version (amd64), server (Ubuntu desktop might work as well)
http://releases.ubuntu.com/14.04/

2. Download scripts from the UnifyCore git repository
https://github.com/unifycore

3. Run install_core.sh script from the unifycore/support directory. This will install the ryu controller framework, ofsoftswitch forwarder and osmocom suite  with its dependencies.
NOTE: We use our custom branches of ofsoftswitch, ryu (with GPRS extensions) and custom vGSN based on osmo-sgsn and OpenGGSN. 

4. Check the version of python-pbr (apt-cache show python-pbr). If the version is lower than 0.6, or higher than 1.0, or equal to 0.7, you need a different version (get it by pip).
sudo apt-get remove python-pbr
sudo pip install pbr

Wrong version of python pbr will be indicated when running the solution by following traceback (in the log file /tmp/controller.log)
Traceback (most recent call last):
...
File "/usr/lib/python2.7/dist-packages/pkg_resources.py", line 628, in resolve
    raise DistributionNotFound(req)
pkg_resources.DistributionNotFound: pbr>=0.6,!=0.7,<1.0
NOTE: 0.10.7 is known to work (pbr -v)

5. Deploy the topology by executing the following script
unifycore/support/network_init.sh
NOTE: The script is written for our test topology, update the interaces according to your needs.

6. Update FWD_ROOT and CNT_SCRIPT variables in the launch script (unifycore/support/sdn.sh) according to your setup. Run the controller by executing the script

7. Have fun!


SAMPLE DEPLOYMENT TOPOLOGIES
-----------------------------
TBD


DEBUG
------

1. Logs of the unifycore are located in /tmp
controller.log
dpa.log
dpb.log
....

2. Restart of the solution/topology
unifycore/support/sdn.sh [start|stop|restart]

3. controller source
ryu/ryu/app/magic.py

4. Topology dump to JSON available at
127.0.0.1:8080/topology/dump


COMMON ISSUES
--------------

1. Traceback (in /tmp/controller.log)
...
File "/usr/lib/python2.7/dist-packages/pkg_resources.py", line 628, in resolve
    raise DistributionNotFound(req)
pkg_resources.DistributionNotFound: pbr>=0.6,!=0.7,<1.0
-wrong version of python-pbr installed. Install different version o pbr, for example from pip

2. Traceback (in /tmp/controller.log)
...
ImportError: No module named magic
-wrong path in the FWD_ROOT and CNT_SCRIPT variables in sdn.sh launch script. Correct the path according to your setup (where is your ofsoftswitch and ryu installed).


USEFUL SCRIPTS
--------------

1. Installation
-installs all applications and dependencies needed to run the project
unifycore/support/install_core.sh

2. Deployment
-sets up the virtual interfaces, fotwarders and links between them (sample topology)
unifycore/support/network_init.sh

3. Running the mobile SDN core
-starts/stops/restarts the controllers and forwarders
unifycore/support/sdn.sh [start|stop|restart]


SUPPORT
--------

unifycore-dev[at]googlegroups.com
