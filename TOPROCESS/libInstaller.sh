#! /bin/bash


# Setup libraries by apt
LIBRARIES=(

)

{
for library in ${LIBRARIES[@]}; do
echo "Installing library: $library"
done
} 2>> errors.log


# Other libs
LIBRARIES=(
https://github.com/msgpack/msgpack-c/archive/refs/tags/cpp-6.1.1.zip
)

{
for library in ${LIBRARIES[@]}; do
rm -rf tmp/*
RESULT=$(cd tmp && wget "$library" && unzip *.zip && cd LIB && mkdir BUILD && cd BUILD && cmake .. && make install)
if (RESULT); then
echo -e "\033[32mOK\033[0m Lib installed!"
else
echo -e "\033[31mERR\033[0m Lib NOT installed!"
fi
done
} 2>> errors.log
