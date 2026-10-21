#! /bin/bash

# Runs generation tests for component CMakeLists

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

function LOG_SEPARATOR() {
    echo -e "============================================="
}
export -f LOG_SEPARATOR

function LOG_DEBUG() {
    echo -e "[ \033[35mDEBG\033[0m ] " $@
    : # Skipper
}
export -f LOG_DEBUG

# =============================================================== #
# =============================================================== #
# =============================================================== #

set -euo pipefail

LOC_TESTS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
LOC_SOURCE_COMPONENTS="$LOC_TESTS_DIR/../../components"
LOC_WORK_DIR=$(mktemp -d)
trap 'rm -rf "$LOC_WORK_DIR"' EXIT

LOC_ENV_COMPONENTS="$LOC_WORK_DIR/components"
mkdir -p "$LOC_ENV_COMPONENTS/depends"
cp -a "$LOC_SOURCE_COMPONENTS/generateComponentCMake.sh" "$LOC_SOURCE_COMPONENTS/subscripts" "$LOC_ENV_COMPONENTS/"

LOC_OS_NAME=$(awk -F= '/^PRETTY_NAME=/{sub(/^PRETTY_NAME=/, ""); gsub(/^"|"$/, ""); print; exit}' /etc/os-release)
if [[ -z $LOC_OS_NAME ]]; then
    LOG_ERROR "Cannot determine OS name from /etc/os-release"
    exit 1
fi

LOC_DEP_MAP_FILE="$LOC_ENV_COMPONENTS/depends/$LOC_OS_NAME.txt"
mkdir -p "$(dirname "$LOC_DEP_MAP_FILE")"
cat > "$LOC_DEP_MAP_FILE" <<'EOF'
Boost.System:boost_system
Boost.Thread:boost_thread
C++FS:stdc++fs
OpenSSL::SSL:ssl
OpenSSL::Crypto:crypto
Sodium:sodium
SQLite3:sqlite3
EOF

LOC_GENERATOR="$LOC_ENV_COMPONENTS/generateComponentCMake.sh"
LOC_STATUS=0

LOG_SEPARATOR
LOG_INFO "Running component CMake generation tests..."

for LOC_CASE_DIR in "$LOC_TESTS_DIR"/*/; do
    LOC_CASE_NAME=$(basename "$LOC_CASE_DIR")
    LOC_RUN_DIR="$LOC_WORK_DIR/$LOC_CASE_NAME"

    LOG_INFO "Checking: $LOC_CASE_NAME"

    mkdir -p "$LOC_RUN_DIR"
    cp -a "$LOC_CASE_DIR/." "$LOC_RUN_DIR/"

    if (! (cd "$LOC_RUN_DIR" && bash "$LOC_GENERATOR")); then
        LOG_ERROR "Generator failed: $LOC_CASE_NAME"
        LOC_STATUS=1
        continue
    fi

    if diff -u "$LOC_CASE_DIR/expected_CMakeLists.txt" "$LOC_RUN_DIR/CMakeLists.txt"; then
        LOG_OK "Passed: $LOC_CASE_NAME"
    else
        LOG_ERROR "Output differs from expected: $LOC_CASE_NAME"
        LOC_STATUS=1
    fi
done

if [[ $LOC_STATUS == 0 ]]; then
    LOG_OK "All component tests passed"
else
    LOG_ERROR "Component tests failed"
fi
LOG_SEPARATOR

exit $LOC_STATUS
