#! /bin/bash

# Set this flag if need APT output
LOC_DEBUG_SHOW_APT_OUTPUT=0

LOC_IDEPS_CLANGFILE="$LOC_MAIN_BASEDIR/data/util/.clang-format"

LOG_SEPARATOR
LOG_INFO "Starting dependency installation ..."

if [[ "$(id -u)" != 0 ]]; then
    LOG_ERROR "Invalid permissions. Try this script as superuser"
    exit 1
fi

while IFS= read -r depname; do
    if ( dpkg-query -W -f='${Status}' $depname 2>/dev/null | grep -q "ok installed" ); then
        LOG_WARNING "Dependency \"$depname\" installed, skipped"
        continue
    fi

    LOG_INFO "Installing dependency: $depname"
    if [ $LOC_DEBUG_SHOW_APT_OUTPUT == 0 ]; then
        echo -e "\n\n\n========================= PACKET: $depname" &>> "$LOC_LOGS_DIR/install_deps_$LOG_START_TIMESTAMP"
        apt install $depname -y &>> "$LOC_LOGS_DIR/install_deps_$LOG_START_TIMESTAMP"
    else
        apt install $depname -y
    fi

    if [ $? ]; then
        LOG_OK "Installed"
    else
        LOG_ERROR "Installation failed"
    fi

done < "$LOC_DEPSFILE"

LOG_OK "Dependency installation completed"
LOG_SEPARATOR
