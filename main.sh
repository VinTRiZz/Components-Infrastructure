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
function LOG_OK() {
    echo -e "[  \033[32mOK\033[0m  ] " $@
}
function LOG_INFO() {
    echo -e "[ \033[37mINFO\033[0m ] " $@
}


# Setup root of project
if [ "$MAIN_PROJECT_ROOTDIR" == "" ]; then
    LOG_ERROR "MAIN_PROJECT_ROOTDIR not set (set as a root of a project)"
    exit 1
fi

# Check if dir is valid
MAIN_PROJECT_ROOTDIR=$(realpath "$MAIN_PROJECT_ROOTDIR")
if  (! test -e "$MAIN_PROJECT_ROOTDIR"); then
    LOG_ERROR "Invalid project root directory: $MAIN_PROJECT_ROOTDIR"
    exit 1
fi

# =============================================================== #
# =============================================================== #
# =============================================================== #


# Common constants
LOC_MAIN_BASEDIR=$(dirname $(realpath "$0"))    # Script directory (avoid reference)
LOC_DEPSFILE=$LOC_MAIN_BASEDIR/depends.txt      # Project dependency packages
LOC_SOURCES=$LOC_MAIN_BASEDIR/sourcedirs.txt    # Project .cpp / .hpp file directories
LOC_SCRIPTS_DIR=$LOC_MAIN_BASEDIR/subscripts

if (! test "$LOC_DEPSFILE" || ! test -e "$LOC_SOURCES" || ! test -e "$LOC_SCRIPTS_DIR" ); then
    LOG_ERROR "Script components and constants check failed. Check if repo is correct"
    exit 1
fi


# Common files check


# Describing
LOC_MAIN_FUNCTIONALITY=(
    "setup-repo     |  Setup git repository (hooks, gitignore)"
    "fix-style      |  Update styles. File \"$(basename $LOC_DEPSFILE))\" hold source dirs"
    "static-check   |  Use cppcheck, clang-tidy on a project"
    ""

    "b  |  Build project in a directory [ ROOT/build ] using CMake"
    "r  |  Same as \"b\" flag, but with installation target"
    "u  |  Start utility component (format code, create doxygen)"
    "d  |  Install project depends (see file \"$(basename $LOC_DEPSFILE))\""
)

# Help
if [[ "$#" == 0 || "$1" == "--help" ]]; then
    echo "============ Welcome to repository master =============="
    echo "Functionality (flags must not combine, first work main):"

    LOC_currentIt=1
    for LOC_mfunc in $(seq 1 ${#LOC_MAIN_FUNCTIONALITY[@]}); do
        echo "$LOC_currentIt) ${LOC_MAIN_FUNCTIONALITY[$LOC_currentIt - 1]}"
        ((LOC_currentIt++))
    done
    exit 0
fi


# =============================================================== #
# =============================================================== #
# =============================================================== #


# TODO: Move top as a constants
if [ "$1" == "setup-repo" ]; then
    exit 0
fi

if [ "$1" == "fix-style" ]; then
    LOG_INFO "Starting style check..."
    bash $LOC_SCRIPTS_DIR/styles.sh
    exit 0
fi


LOG_ERROR "Invalid arguments passed"
exit 1
