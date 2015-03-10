#!/bin/bash

#Unifycore installation scrip
#Scripts installs all needed Unifycore infrastructure


# run me as root on ubuntu 14.04/amd64

apt-get install -y vim-nox tcpdump screen bc tcptraceroute debian-keyring links nmap patch iptraf subversion wget cron make openssl-blacklist traceroute
sudo update-alternatives --set editor /usr/bin/vim.nox

apt-get install -y libdbi0-dev libdbd-sqlite3 build-essential libtool autoconf automake git-core pkg-config libortp-dev build-essential unzip cmake libpcap-dev libxerces-c2-dev libpcre3-dev flex bison pkg-config autoconf automake libtool libboost-dev rsync git subversion libcurl4-openssl-dev python-setuptools python-pip python-dev dnsmasq valgrind

apt-get install -y libpcsclite-dev

# don't forget to change this crendentials to actual github credentials
# for committing to the Unifycore repository, setup the ssh keys (guide available on github)
git config --global user.name "Jan Skalny"
git config --global user.email jan@skalny.sk

cd
git clone git://git.osmocom.org/libosmocore.git
git clone git://git.osmocom.org/libosmo-abis.git
git clone git://git.osmocom.org/libosmo-netif.git
git clone git://git.osmocom.org/openggsn.git
git clone git://github.com/unifycore/openbsc.git
git clone git://github.com/unifycore/unifycore.git
git clone git://github.com/unifycore/ryu.git
git clone git://github.com/unifycore/ofsoftswitch13.git

cd ~/ryu ; git remote set-url origin git@github.com:unifycore/ryu.git
cd ~/ofsoftswitch13 ; git remote set-url origin git@github.com:unifycore/ofsoftswitch13.git
cd ~/unifycore ; git remote set-url origin git@github.com:unifycore/unifycore.git
cd ~/openbsc ; git remote set-url origin git@github.com:unifycore/openbsc.git

cd ~/openggsn; libtoolize -c -f -i ; autoreconf; automake --add-missing; autoreconf; autoconf; automake; ./configure --prefix=/usr/local; make -j 2; make install ; ldconfig
cd ~/libosmocore; autoreconf -fi; ./configure; make; make install; ldconfig
cd ~/libosmo-abis; autoreconf -fi; ./configure; make; make install; ldconfig
cd ~/libosmo-netif; autoreconf -fi; ./configure; make; make install; ldconfig
cd ~/openbsc/openbsc; autoreconf -fi; export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig; ./configure; make

cd ~/
wget http://www.nbee.org/download/nbeesrc-jan-10-2013.php -O nbee.zip && unzip nbee.zip && rm nbee.zip
cd ~/nbeesrc-jan-10-2013/
patch src/nbpflcompiler/gramm.y < ~/unifycore/patches/nbeesrc-jan-10-2013/bison3.diff 
patch src/nbprotodb/expressions.cpp < ~/unifycore/patches/nbeesrc-jan-10-2013/bison26.diff 
cd ~/nbeesrc-jan-10-2013/src/
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


echo "172.20.255.254  internet" >> /etc/hosts
echo "dhcp-range=192.168.27.100,192.168.27.200,12h" >> /etc/dnsmasq.conf
echo "interface=vgsn0" >> /etc/dnsmasq.conf

