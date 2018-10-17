#!/bin/bash

# groestlcoin-core | install/setup | 18.04 bionic_beaver
# https://github.com/groestlcoin/groestlcoin

BRANCH=master
#BRANCHTAG= # edit && uncomment in GITCLONEFUNC | git fetch --all --tags && #git checkout tags/$BRANCHTAG -b master

sudo chown -R $USER:$USER /opt # chown target dir for $GITREPOROOT
GITREPOROOT=/opt/groestlcoin/groestlcoin/groestlcoin
GITCLONEDIR=/opt/groestlcoin/groestlcoin
GITREPO=https://github.com/groestlcoin/groestlcoin.git
MAKEJ=2 # make threads

BINDIR=/usr/local/bin

# font
bold=$(tput bold)
normal=$(tput sgr0)
#END font

GITRESET () {
cd $GITREPOROOT
	make clean
	git clean -f
	git fetch origin
	git reset --hard origin/$BRANCH
	git pull
}

# init submodules
GITSBMDLINIT () {
	git submodule init
	git submodule update --recursive
	sudo updatedb && sudo ldconfig
}
# END init submodules

# git clone
GITCLONEFUNC () {
mkdir -p $GITCLONEDIR
cd $GITCLONEDIR
git clone -b $BRANCH $GITREPO
#git fetch --all --tags
#git checkout tags/$BRANCHTAG -b $BRANCH
cd $GITREPOROOT
}
# END git clone

INSTDEPS () {
sudo apt-get update
sudo apt-get upgrade

LIBS_DEPS="libboost-all-dev
libboost-system-dev
libboost-filesystem-dev
libboost-chrono-dev
libboost-program-options-dev
libboost-test-dev
libboost-thread-dev
libqrencode-dev
libprotobuf-dev
libzmq3-dev
libminiupnpc-dev
libevent-dev
libdb++-dev
libdb5.3
libdb5.3-dev
libdb5.3++-dev
"

LIBS_QT5_DEPS="libqt5gui5
libqt5core5a
libqt5dbus5
qttools5-dev
qttools5-dev-tools
"

DEPS_MAIN="protobuf-compiler
software-properties-common
build-essential
libtool
autotools-dev
automake
pkg-config
libssl-dev
libevent-dev
bsdmainutils
python3
git
ntp
make
autoconf
cpp
ngrep
iftop
sysstat
"
sudo apt-get update
sudo apt-get upgrade

echo $LIBS_DEPS | while read libsdeps
do
   sudo apt-get install -y $libsdeps
done

echo $LIBS_QT5_DEPS | while read libsqt5deps
do
   sudo apt-get install -y $libsqt5deps
done

echo $DEPS_MAIN | while read depsmain
do
   sudo apt-get install -y $depsmain
done

sudo updatedb
sudo ldconfig
}

BUILD () {
cd $GITREPOROOT

# sed -i -e 's/MAX_OUTBOUND_CONNECTIONS = 8/MAX_OUTBOUND_CONNECTIONS = 254/g' $GITREPOROOT/src/net.h
# sed -i -e 's/DEFAULT_MAX_PEER_CONNECTIONS = 125/DEFAULT_MAX_PEER_CONNECTIONS = 1024/g' $GITREPOROOT/src/net.h

./autogen.sh
./configure # (other args...)
#./configure --enable-hardening
sudo updatedb
sudo ldconfig

make -j $MAKEJ
sudo make install
}

CHECKINST () {
if [ ! -f $GITREPOROOT/src/groestlcoind ]; then
echo "${bold}404 ERROR: groestlcoind exec. not found in $GITREPOROOT/src/groestlcoind, something went wrong - check the console output!${normal}"
else
echo "${bold}Congrats! groestlcoind exec found in $GITREPOROOT/src/groestlcoind!${normal}"
fi

if [ ! -f $GITREPOROOT/src/qt/bitcoin-qt ]; then
echo "${bold}404 ERROR: groestlcoin-qt exec. not found in $GITREPOROOT/src/qt/groestlcoin-qt, something went wrong - check the console output!${normal}"
else
echo "${bold}Congrats! groestlcoin-qt exec found in $GITREPOROOT/src/groestlcoin-qt!${normal}"
fi
}

####
UPDATEALTERNATIVEGCC () {

# 18.04 bionic-beaver
# default 14.5.18 - gcc version 7.3.0 (Ubuntu 7.3.0-16ubuntu3)
# edit line 44 && 46 to change default version | yes "4" << version 4 as in the variables is gcc / g++ 7

sudo apt-get update
sudo apt-get upgrade

DEFAULT=40 # 40 for $VERSION4 default gcc/g++ version , 10 - X
VERSION1=4.8
VERSION2=5
VERSION3=6
VERSION4=7
VERSION5=8

sudo apt-get install gcc-4.8 gcc-5 gcc-6 gcc-7 gcc-8 g++-4.8 g++-5 g++-6 g++-7 g++-8


dpkg --list | grep compiler

sudo update-alternatives --remove-all gcc
sudo update-alternatives --remove-all g++

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$VERSION1 10
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$VERSION2 20
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$VERSION3 30
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$VERSION4 40
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$VERSION5 50

sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$VERSION1 10
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$VERSION2 20
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$VERSION3 30
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$VERSION4 40
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$VERSION5 50


sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc $DEFAULT
sudo update-alternatives --set cc /usr/bin/gcc

sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ $DEFAULT
sudo update-alternatives --set c++ /usr/bin/g++

yes "4" | sudo update-alternatives --config gcc
# expect "Press <enter> to keep the current choice[*], or type selection number:" { send "\n" }
yes "4" | sudo update-alternatives --config g++
# expect "Press <enter> to keep the current choice[*], or type selection number:" { send "\n" }
gcc -v
g++ -v
}

GCCDEFAULT () {
yes "4" | sudo update-alternatives --config gcc
# expect "Press <enter> to keep the current choice[*], or type selection number:" { send "\n" }
yes "4" | sudo update-alternatives --config g++
# expect "Press <enter> to keep the current choice[*], or type selection number:" { send "\n" }
gcc -v
g++ -v
}

ECHOCONF () {
mkdir -p /home/$USER/.groestlcoin
groestlcoind --help > /home/$USER/.groestlcoin/groestlcoin.conf_example
}

if [ ! -f $GITREPOROOT/src/groestlcoind ]; then
INSTDEPS
GITCLONEFUNC
GITSBMDLINIT
UPDATEALTERNATIVEGCC
BUILD
GCCDEFAULT
CHECKINST
ECHOCONF
echo "done - git-clone, build && setup, checkconsole output"

else

GITRESET
UPDATEALTERNATIVEGCC
BUILD
GCCDEFAULT
CHECKINST
ECHOCONF
echo "done - clean, build && setup, checkconsole output"

fi
