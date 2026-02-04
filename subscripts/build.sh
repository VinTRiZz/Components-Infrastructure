#! /bin/bash

# Builds project with release or not release target

# Set this flag to see what CMake print without logs directory managing
LOC_DEBUG_SHOW_CMAKE_OUTPUT=0

LOC_BUILD_DIR=$MAIN_PROJECT_ROOTDIR/build

LOG_SEPARATOR
LOG_INFO "Starting project build..."

rm -r "$LOC_BUILD_DIR"/* &> /dev/null
if [ "$?" != "0" ]; then
    mkdir "$LOC_BUILD_DIR"
fi

if [ "$?" != "0" ]; then
    LOG_ERROR "Failed to create or clean build directory"
    LOG_INFO "===> Maybe, you tried to build with sudo and now - without?"
    exit 1
fi
cd "$LOC_BUILD_DIR"


# TODO: Найти человеческий способ
if [ $LOC_DEBUG_SHOW_CMAKE_OUTPUT == 0 ]; then
    if [ "$1" == "release" ]; then
        cmake -DCMAKE_BUILD_TYPE=Release -GNinja .. &> "$LOC_LOGS_DIR/build_configure_$LOG_START_TIMESTAMP.log"
    else
        cmake -DCMAKE_BUILD_TYPE=Debug -GNinja .. &> "$LOC_LOGS_DIR/build_configure_$LOG_START_TIMESTAMP.log"
    fi

    if [ $? != 0 ]; then
        LOG_ERROR "Failed to configure project"
        exit 1
    fi

    cmake --build . --target all -- -j$(nproc) &> "$LOC_LOGS_DIR/build_$LOG_START_TIMESTAMP.log"
    if [ $? != 0 ]; then
        LOG_ERROR "Failed to build project"
        exit 1
    fi

else

    if [ "$1" == "release" ]; then
        cmake -DCMAKE_BUILD_TYPE=Release -GNinja ..
    else
        cmake -DCMAKE_BUILD_TYPE=Debug -GNinja ..
    fi

    if [ $? != 0 ]; then
        LOG_ERROR "Failed to configure project"
        exit 1
    fi

    cmake --build . --target all -- -j$(nproc) $LOG_BUILD_ARG
    if [ $? != 0 ]; then
        LOG_ERROR "Failed to build project"
        exit 1
    fi
fi

LOG_OK "Project build succeed"
LOG_SEPARATOR
