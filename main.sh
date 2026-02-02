#! /bin/bash

# Work on this script started on 02.02.2026
# It will hold on many functionality i hate to call
# every time for every thing
# Btw, it created to work with my small projects easier

# =============================================================== #
# =============================================================== #
# =============================================================== #


# Setup root of project
if [ "$MAIN_PROJECT_ROOTDIR" == "" ]; then
    echo "MAIN_PROJECT_ROOTDIR not set"
    echo "Set it as a root of your repository"
    exit 1
fi

# Check if dir is valid
MAIN_PROJECT_ROOTDIR=$(realpath "$MAIN_PROJECT_ROOTDIR")
if  (! test -e "$MAIN_PROJECT_ROOTDIR"); then
    echo "Invalid root directory: $MAIN_PROJECT_ROOTDIR"
    exit 1
fi

# =============================================================== #
# =============================================================== #
# =============================================================== #


# Common constants
LOC_MAIN_BASEDIR=$(dirname $(realpath "$0"))    # Script directory (avoid reference)
LOC_DEPSFILE=$LOC_MAIN_BASEDIR/depends.txt      # Project constants file

# Describing
LOC_MAIN_FUNCTIONALITY=(
    "s  |  Setup project repository (hooks, gitignore)"
    "b  |  Build project in a directory [ ROOT/build ] using CMake"
    "r  |  Same as \"b\" flag, but with installation target"
    "u  |  Start utility component (format code, create doxygen)"
    "d  |  Install project depends (see file \"$(basename $LOC_DEPSFILE))\""
)

# Help
if [[ "$?" == 0 || "$1" == "--help" ]]; then
    echo "============ Welcome to repository master =============="
    echo "Functionality (flags must not combine, first work main):"

    LOC_currentIt=1
    for LOC_mfunc in $(seq 1 ${#LOC_MAIN_FUNCTIONALITY[@]}); do
        echo "$LOC_currentIt) ${LOC_MAIN_FUNCTIONALITY[$LOC_currentIt - 1]}"
        ((LOC_currentIt++))
    done
    exit 0
fi

