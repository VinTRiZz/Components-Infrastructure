#! /bin/bash


INSTALLATIONS=(

# Compilation
build-essential
gcc
make
cmake
extra-cmake-modules
ninja-build

# libs
libboost-all-dev

libxnvctrl0
libxnvctrl-dev

libfmt-dev

libjsoncpp-dev
nlohmann-json3-dev

libmysqlcppconn-dev
libmysqlclient-dev
libsqlite3-dev
libmysql++-dev

libpistache-dev

opencl-clhpp-headers

libcpuid-dev
)

sudo apt update && sudo apt upgrade -y &> /dev/null

for installPacket in ${INSTALLATIONS[@]}; do
if (dpkg -l "$installPacket" &> /dev/null); then
echo -e "\033[32mOK\033[0m Package already installed: $installPacket"
else
sudo apt install "$installPacket" -y
fi
done
