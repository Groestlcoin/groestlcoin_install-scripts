#!/bin/bash

# monerod | install/setup | 18.04 bionic_beaver
# https://github.com/monero-project/monero

# The script installs the GCC / G++ alternatives set and sets latest GCC / G++ 8 as default after the installation
# to change edit GCCDEFAULT

# GCC / G++ 8 build fail
# /opt/Crypto_Coin-Clients/monero/monero-project/monero/src/cryptonote_basic/account.cpp:160:34: error: ‘void* memset(void*, int, size_t)’ clearing an object of non-trivial type ‘using secret_key = struct tools::scrubbed<crypto::ec_scalar>’ {aka ‘struct tools::scrubbed<crypto::ec_scalar>’}; use assignment or value-initialization instead [-Werror=class-memaccess]
#      memset(&fake, 0, sizeof(fake));

# using 7 instead see

sudo chown -R $USER:$USER /opt # chown target dir for $GITREPOROOT

BRANCH=master
# to modify target path also edit "ADDPATH" functin ~ line 90
GITREPOROOT=/opt/Crypto_Coin-Clients/monero/monero-project/monero
GITCLONEDIR=/opt/Crypto_Coin-Clients/monero/monero-project
GITREPO=https://github.com/monero-project/monero
MAKEJ=2 # make threads

# symlink
EXECUTEABLE1=monerod
EXECUTEABLE2=monerod
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
git clone --recursive -b $BRANCH $GITREPO
cd $GITREPOROOT
}

INSTDEPS () {
sudo apt-get update
sudo apt-get upgrade

LIBS_DEPS="libboost-all-dev
libssl-dev
libzmq3-dev
libunbound-dev
libsodium-dev
libminiupnpc-dev
libunwind8-dev
liblzma-dev
libreadline6-dev
libldns-dev
libexpat1-dev
libgtest-dev
"

DEPS_MAIN="cmake
build-essential
pkg-config
doxygen
graphviz
git
"

echo $LIBS_DEPS | while read libsdeps
do
   sudo apt-get install -y $libsdeps
done

# On Debian/Ubuntu libgtest-dev only includes sources and headers. You must build the library binary manually. This can be done with the following command
cd /usr/src/gtest && sudo cmake . && sudo make && sudo mv libg* /usr/lib/

echo $DEPS_MAIN | while read depsmain
do
   sudo apt-get install -y $depsmain
done

sudo updatedb
sudo ldconfig
}

BUILD () {
make -j $MAKEJ
}

CHECKINST () {
if [ ! -f $GITREPOROOT/build/release/bin/monerod ]; then
echo "${bold}404 ERROR: monerod exec. not found in $GITREPOROOT/build/release/bin/monerod, something went wrong - check the console output!${normal}"
else
echo "${bold}Congrats! monerod exec found in $GITREPOROOT/build/release/bin/monerod!${normal}"
fi
}

ADDPATH () {
sed -i -e 's#PATH="$PATH:/opt/Crypto_Coin-Clients/monero/monero-project/monero/build/release/bin"##g' .profile
echo 'PATH="$PATH:/opt/Crypto_Coin-Clients/monero/monero-project/monero/build/release/bin"' >> .profile
source .profile
}

SYMLINK () {
sudo rm -f $BINDIR/$EXECUTEABLE2
sudo ln -s $GITREPOROOT/build/release/bin/$EXECUTEABLE1 $BINDIR/$EXECUTEABLE2
}

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
yes "0" | sudo update-alternatives --config gcc 
# expect "Press <enter> to keep the current choice[*], or type selection number:" { send "\n" }
yes "0" | sudo update-alternatives --config g++ 
# expect "Press <enter> to keep the current choice[*], or type selection number:" { send "\n" }
gcc -v
g++ -v
}

ECHOCONF () {
mkdir -p /home/$USER/.monero
monerod --help > /home/$USER/.monero/monerod.conf_example
}


if [ ! -f $GITREPOROOT/build/release/bin/monerod ]; then
INSTDEPS # install dependencies
GITCLONEFUNC # git-clone
GITSBMDLINIT # submodules init
UPDATEALTERNATIVEGCC # update alternatives, use GCC / G++ 7
BUILD # build
# ADDPATH
GCCDEFAULT # revert alternatives changes
SYMLINK # symlink the monerod exec from $GITREPOROOT/build/release/bin/monerod
CHECKINST # check if executeable was build successfully in $GITREPOROOT/build/release/bin/monerod
ECHOCONF # echo sample config to /home/$USER/.monero/monerod.conf_example
echo "done - git-clone, build && setup, checkconsole output"

else

GITRESET
UPDATEALTERNATIVEGCC # update alternatives, use GCC / G++ 7
BUILD # build
# ADDPATH
GCCDEFAULT # revert alternatives changes
SYMLINK # symlink the monerod exec from $GITREPOROOT/build/release/bin/monerod
CHECKINST # check if executeable was build successfully in $GITREPOROOT/build/release/bin/monerod
ECHOCONF # echo sample config to /home/$USER/.monero/monerod.conf_example
echo "done - clean, build && setup, checkconsole output"

fi