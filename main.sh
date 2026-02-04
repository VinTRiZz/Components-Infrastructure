#! /bin/bash

# Work on this script started on 02.02.2026
# It will hold on many functionality i hate to call
# every time for every thing
# Btw, it created to work with my small projects easier

# =============================================================== #
# =============================================================== #
# =============================================================== #

# Functions to use from internal
function LOG_ERROR() {
    echo -e "[ \033[31mFAIL\033[0m ] " $@
}
export -f LOG_ERROR

function LOG_OK() {
    echo -e "[  \033[32mOK\033[0m  ] " $@
}
export -f LOG_OK

function LOG_INFO() {
    echo -e "[ \033[36mINFO\033[0m ] " $@
}
export -f LOG_INFO

function LOG_WARNING() {
    echo -e "[ \033[33mWARN\033[0m ] " $@
}
export -f LOG_WARNING

# По приколу?
function LOG_SEPARATOR() {
    echo -e "============================================="
}
export -f LOG_SEPARATOR

# Uncomment if need
function LOG_DEBUG() {
    echo -e "[ \033[35mDEBG\033[0m ] " $@
    : # Skipper
}
export -f LOG_DEBUG

# Check if dir is valid
MAIN_PROJECT_ROOTDIR=$(realpath "$MAIN_PROJECT_ROOTDIR")
while (! test -d "$MAIN_PROJECT_ROOTDIR"); do
    LOG_ERROR "Invalid project root directory: $MAIN_PROJECT_ROOTDIR"
    read -e -p "Write project directory: >>> " MAIN_PROJECT_ROOTDIR
    MAIN_PROJECT_ROOTDIR=$(eval realpath $MAIN_PROJECT_ROOTDIR)
done

# =============================================================== #
# =============================================================== #
# =============================================================== #


# Common
export LOC_MAIN_BASEDIR=$(dirname $(realpath "$0"))         # Script directory (avoid reference)
export LOC_SCRIPTS_DIR=$LOC_MAIN_BASEDIR/subscripts         # Components of this script
export LOG_START_TIMESTAMP=$(date +%d.%m.%Y_%H-%M-%S)       # Timestamp for logs
export LOC_LOGS_DIR=$LOC_MAIN_BASEDIR/logs                  # For logging from some components

# Configs
export LOC_DEPSFILE=$LOC_MAIN_BASEDIR/config/depends.txt    # Project dependency packages
export LOC_SOURCES=$LOC_MAIN_BASEDIR/config/sourcedirs.txt  # Project .cpp / .hpp file directories
export LOC_INCLUDES=$LOC_MAIN_BASEDIR/config/includedirs.txt  # Project special include directories
export LOC_DOXYCONF=$LOC_MAIN_BASEDIR/config/doxyconf.txt   # Doxygen documentation

if (! test "$LOC_DEPSFILE" ||
    ! test -e "$LOC_SOURCES" ||
    ! test -e "$LOC_SCRIPTS_DIR" ||
    ! test -e "$LOC_DOXYCONF" ); then
    LOG_ERROR "Script components and constants check failed. Check if repo is correct"
    exit 1
fi

mkdir "$LOC_LOGS_DIR" &> /dev/null # For logging from some components

# Info and subscript work
declare -A LOC_MAIN_FUNCTIONALITY
LOC_MAIN_FUNCTIONALITY["setup-repo"]="Setup git repository (hooks, gitignore)"
LOC_MAIN_FUNCTIONALITY["fix-style"]="Update styles. File \"$(basename $LOC_DEPSFILE)\" hold source dirs"
LOC_MAIN_FUNCTIONALITY["gen-docs"]="Generate documentation configuring Doxygen using constants from "

# Depends
LOC_MAIN_FUNCTIONALITY["install-deps"]="Install project depends (see file \"$(basename $LOC_DEPSFILE))\""

# C++ things
LOC_MAIN_FUNCTIONALITY["static-check"]="Use cppcheck, clang-tidy on a project"
LOC_MAIN_FUNCTIONALITY["build"]="Build project in a directory [ ROOT/build ] using CMake"
LOC_MAIN_FUNCTIONALITY["build-release"]="Same as \"b\" flag, but with installation target"


# Help
if [[ "$#" == 0 || "$1" == "--help" ]]; then
    echo "============ Welcome to repository master =============="
    echo "Most cases, script is all you need to handle a project"
    echo "Functionality (flags must not combine, first work main):"

    for LOC_scriptname in ${!LOC_MAIN_FUNCTIONALITY[@]}; do
        printf "%-15s | %s\n" "$LOC_scriptname" "${LOC_MAIN_FUNCTIONALITY[$LOC_scriptname]}"
    done
    exit 0
fi


# =============================================================== #
# =============================================================== #
# =============================================================== #

LOG_DEBUG "Args: $@"
LOG_DEBUG "Working directory:" $MAIN_PROJECT_ROOTDIR
LOG_DEBUG "Logs directory: $LOC_LOGS_DIR"

if [[ -v LOC_MAIN_FUNCTIONALITY["$1"] ]]; then
    bash "$LOC_SCRIPTS_DIR/$1.sh"
    exit 0
fi
LOG_ERROR "Invalid argument: $1"
