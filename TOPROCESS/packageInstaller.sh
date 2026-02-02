#! /bin/bash

INSTALLATIONS=(

# Common
kde-plasma-desktop
kde-spectacle   # Screenshotter
fish            # Shell
curl
htop
testdisk        # File restore utility
thermald        # For processor throttling

# Compilation
build-essential
gcc
make
cmake
libboost-all-dev
linux-headers-$(uname -r)

# For ossec
libssl-dev
libcrypto++-dev
libpcre2-dev

# Coding
qtcreator
codeblocks-contrib
gdb

# Etc
pciutils
linux-headers-$(uname -r)

# Network
ufw     # Firewall
nmap    # Network scanning

)

{
apt update && apt upgrade -y &> /dev/null

for installPacket in ${INSTALLATIONS[@]}; do
if (dpkg -l "$installPacket" &> /dev/null); then
echo -e "\033[32mOK\033[0m Package already installed: $installPacket"
else
apt install "$installPacket" -y
fi
done
} 2>> errors.log
