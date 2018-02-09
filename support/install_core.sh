#!/bin/bash

#Unifycore installation scrip
#Scripts installs all needed Unifycore infrastructure


# run me as root on ubuntu 14.04/amd64

apt-get install -y vim-nox tcpdump screen bc tcptraceroute debian-keyring links nmap patch iptraf subversion wget cron make openssl-blacklist traceroute
sudo update-alternatives --set editor /usr/bin/vim.nox

apt-get install -y libdbi0-dev libdbd-sqlite3 build-essential libtool autoconf automake git-core pkg-config libortp-dev build-essential unzip cmake libpcap-dev libxerces-c2-dev libpcre3-dev flex bison pkg-config autoconf automake libtool libboost-dev rsync git subversion libcurl4-openssl-dev python-setuptools python-pip python-dev dnsmasq valgrind

apt-get install -y libpcsclite-dev jq libffi-dev python-paramiko python-oslo.config

# don't forget to change this crendentials to actual github credentials
# for committing to the Unifycore repository, setup the ssh keys (guide available on github)
git config --global user.name "Tibor Hirjak"
git config --global user.email hirjak.tibor@gmail.com


cd
git clone git://git.osmocom.org/libosmocore.git
git clone git://git.osmocom.org/libosmo-abis.git
git clone git://git.osmocom.org/libosmo-netif.git
git clone git://git.osmocom.org/openggsn.git
git clone git://github.com/unifycore/openbsc.git
git clone git://github.com/unifycore/unifycore.git
git clone git://github.com/unifycore/ryu.git
git clone git://github.com/unifycore/ofsoftswitch13.git
git clone https://github.com/unifycore/bss-sim.git



cd ~/ryu ; git remote set-url origin git@github.com:unifycore/ryu.git
cd ~/ofsoftswitch13 ; git remote set-url origin git@github.com:unifycore/ofsoftswitch13.git
cd ~/unifycore ; git remote set-url origin git@github.com:unifycore/unifycore.git
cd ~/openbsc ; git remote set-url origin git@github.com:unifycore/openbsc.git
cd ~/bss-sim ; git remote set-url origin git@github.com:unifycore/bss-sim.git


### So since we forgot to fork also OSMO stuff....meh
### the brand new, refactored OSMO code does not work with our stuff
### I was able to figure out some commits from OSMO master branches (rather old ones, from some anchient virtual machine, meh2 :/ )...hope it work well for everyone

# Date:   Tue Dec 23 19:52:54 2014 +0100
cd ~/openggsn; git reset --hard 91d0ee5c140a7b9cff8fb71d7fd19025a92bc71b
# Date:   Tue Jan 27 11:06:51 2015 +0100
cd ~/libosmocore; git reset --hard 879acef39465bb978f9a3bcb349594b818aec442
# Sun Jan 18 19:27:07 2015 +0100
cd ~/libosmo-abis; git reset --hard 2f0dd0c01930fbc0dbf0c86946dd0a429f3cd6e2
# Wed Feb 25 11:17:51 2015 +0100
cd ~/libosmo-netif; git reset --hard 2f1ddb2709fcdccdbc5830de4cec0f0a7141ecbd

### End of bloody hack


cd ~/openggsn; libtoolize -c -f -i ; autoreconf; automake --add-missing; autoreconf; autoconf; automake; ./configure --prefix=/usr/local; make -j 2; make install ; ldconfig
cd ~/libosmocore; autoreconf -fi; ./configure; make; make install; ldconfig
cd ~/libosmo-abis; autoreconf -fi; ./configure; make; make install; ldconfig
cd ~/libosmo-netif; autoreconf -fi; ./configure; make; make install; ldconfig
cd ~/openbsc/openbsc; autoreconf -fi; export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig; ./configure; make


### Geeee, look also nbee does not work anymore, I guess it was put to ofsoftswitch mainline
### Anyhow, to tired to fixed it properly, hope you dont mind
### (oh yes, I forgot, we forked ofsoftswitch and have GPRS extensions there, so we cannot use ofsoftwirch mainline that easily)

cd ~/
git clone https://github.com/netgroup-polito/netbee.git
cd ~/netbee/
patch src/nbpflcompiler/gramm.y < ~/unifycore/patches/nbeesrc-jan-10-2013/bison3.diff 

# Hmmm, hmmm, this btw fails, somehow it seems to be working anyhow (or perhabs I am halucinating...)
patch src/nbprotodb/expressions.cpp < ~/unifycore/patches/nbeesrc-jan-10-2013/bison26.diff 
cd ~/netbee/src/
cmake .
make
mkdir -p /usr/local/lib
rsync -avP ../bin/*.so /usr/local/lib/
rsync -avP ../include/ /usr/include/
ldconfig

cd ~/ofsoftswitch13/
./boot.sh
./configure
make
make install

cd ~/ryu
python ./setup.py install
pip install networkx
pip install debtcollector
pip install stevedore
pip install greenlet
easy_install cryptography
pip install netaddr
pip install webob
pip install routes
pip install eventlet

echo "172.20.255.254  internet" >> /etc/hosts
echo "dhcp-range=192.168.27.100,192.168.27.200,12h" >> /etc/dnsmasq.conf
echo "interface=vgsn0" >> /etc/dnsmasq.conf

