#! /bin/bash

# Generates CMakeLists.txt for a component from cs_sys/manifest.ini

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

LOC_COMPONENTS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
LOC_MANIFEST=cs_sys/manifest.ini
LOC_PARSER="$LOC_COMPONENTS_DIR/subscripts/parse_manifest.awk"

function SPLIT_LIST() {
    local LOC_VALUE=$1
    local LOC_ITEM
    local -a LOC_ITEMS

    IFS=',' read -r -a LOC_ITEMS <<< "$LOC_VALUE"
    for LOC_ITEM in "${LOC_ITEMS[@]}"; do
        LOC_ITEM=${LOC_ITEM#"${LOC_ITEM%%[![:space:]]*}"}
        LOC_ITEM=${LOC_ITEM%"${LOC_ITEM##*[![:space:]]}"}
        if [[ -n $LOC_ITEM ]]; then
            printf '%s\n' "$LOC_ITEM"
        fi
    done
}

function SWITCH_VARIABLE() {
    case "$1" in
        tests_enabled) printf 'COMPONENTS_ENABLE_TESTS\n' ;;
        qt_enabled) printf 'COMPONENTS_IS_ENABLED_QT\n' ;;
        *) printf 'COMPONENTS_SW_%s\n' "$1" ;;
    esac
}

LOG_SEPARATOR
LOG_INFO "Generating CMakeLists.txt for component in $PWD"

if (! test -d src); then
    LOG_ERROR "Missing source directory: $PWD/src"
    exit 1
fi

if (! test -f "$LOC_MANIFEST"); then
    LOG_ERROR "Missing component manifest: $PWD/$LOC_MANIFEST"
    exit 1
fi

if (! test -f "$LOC_PARSER"); then
    LOG_ERROR "Missing manifest parser: $LOC_PARSER"
    exit 1
fi

declare -A LOC_SYSTEM=()
declare -a LOC_SWITCHES=()
declare -A LOC_SW_DEFAULT=()
declare -A LOC_SW_DEPENDS=()
declare -A LOC_SW_COMPONENTS=()
declare -A LOC_SW_SOURCES=()
declare -A LOC_SW_PRECOMPILED=()
declare -A LOC_SW_INCLUDES=()

while IFS=$'\t' read -r LOC_SECTION LOC_KEY LOC_VALUE; do
    if [[ $LOC_SECTION == system ]]; then
        LOC_SYSTEM[$LOC_KEY]=$LOC_VALUE
    elif [[ $LOC_SECTION == switches.* ]]; then
        LOC_SWITCH=${LOC_SECTION#switches.}
        if [[ -z ${LOC_SW_DEFAULT[$LOC_SWITCH]+set} ]]; then
            LOC_SWITCHES+=("$LOC_SWITCH")
            LOC_SW_DEFAULT[$LOC_SWITCH]=none
        fi
        case $LOC_KEY in
            default) LOC_SW_DEFAULT[$LOC_SWITCH]=$LOC_VALUE ;;
            depends) LOC_SW_DEPENDS[$LOC_SWITCH]=$LOC_VALUE ;;
            depends-components) LOC_SW_COMPONENTS[$LOC_SWITCH]=$LOC_VALUE ;;
            sources) LOC_SW_SOURCES[$LOC_SWITCH]=$LOC_VALUE ;;
            precompiled) LOC_SW_PRECOMPILED[$LOC_SWITCH]=$LOC_VALUE ;;
            includes) LOC_SW_INCLUDES[$LOC_SWITCH]=$LOC_VALUE ;;
        esac
    fi
done < <(awk -f "$LOC_PARSER" "$LOC_MANIFEST")

LOC_NAME=${LOC_SYSTEM[name]:-}
LOC_VERSION=${LOC_SYSTEM[version]:-}
LOC_VERSION=${LOC_VERSION#\"}
LOC_VERSION=${LOC_VERSION%\"}

if [[ -z $LOC_NAME ]]; then
    LOG_ERROR "Missing 'name' in [system]"
    exit 1
fi

if [[ -z $LOC_VERSION ]]; then
    LOG_ERROR "Missing 'version' in [system]"
    exit 1
fi

LOC_COMPONENT=${LOC_NAME#Components-}
LOC_TARGET=Components-$LOC_COMPONENT

for LOC_SWITCH in "${LOC_SWITCHES[@]}"; do
    LOC_DEFAULT=${LOC_SW_DEFAULT[$LOC_SWITCH]:-none}
    case ${LOC_DEFAULT,,} in
        none|'') LOC_SW_DEFAULT[$LOC_SWITCH]=none ;;
        on) LOC_SW_DEFAULT[$LOC_SWITCH]=ON ;;
        off) LOC_SW_DEFAULT[$LOC_SWITCH]=OFF ;;
        *)
            LOG_ERROR "Invalid default '$LOC_DEFAULT' for switch '$LOC_SWITCH'"
            exit 1
            ;;
    esac
done

declare -A LOC_DEP_MAP=()
LOC_DEP_MAP_READY=0
LOC_DEP_MAP_FILE=
LOC_RESOLVED_DEP=

function LOAD_DEP_MAP() {
    local LOC_OS_NAME
    local LOC_LINE
    local LOC_ORIGINAL_LINE
    local LOC_KEY
    local LOC_VALUE

    LOC_OS_NAME=$(awk -F= '/^PRETTY_NAME=/{sub(/^PRETTY_NAME=/, ""); gsub(/^"|"$/, ""); print; exit}' /etc/os-release)
    if [[ -z $LOC_OS_NAME ]]; then
        LOG_WARNING "Cannot determine OS name from /etc/os-release, using dependency names as-is"
        LOC_DEP_MAP_READY=1
        return
    fi

    LOC_DEP_MAP_FILE="$LOC_COMPONENTS_DIR/depends/$LOC_OS_NAME.txt"
    if (! test -f "$LOC_DEP_MAP_FILE"); then
        LOG_WARNING "Dependency map not found: $LOC_DEP_MAP_FILE, using dependency names as-is"
        LOC_DEP_MAP_READY=1
        return
    fi

    LOG_INFO "Loading dependency map: $LOC_DEP_MAP_FILE"

    while IFS= read -r LOC_LINE || [[ -n $LOC_LINE ]]; do
        LOC_LINE=${LOC_LINE%$'\r'}
        if [[ $LOC_LINE =~ ^[[:space:]]*(#|;) ]] || [[ $LOC_LINE =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        if [[ $LOC_LINE != *:* ]]; then
            LOG_WARNING "Invalid dependency map line: $LOC_LINE"
            continue
        fi

        LOC_ORIGINAL_LINE=$LOC_LINE
        LOC_LINE=$(printf '%s\n' "$LOC_LINE" | sed 's/\([^:]\):\([^:]\)/\1\t\2/')
        if [[ $LOC_LINE != *$'\t'* ]]; then
            LOG_WARNING "Invalid dependency map line: $LOC_ORIGINAL_LINE"
            continue
        fi

        LOC_KEY=${LOC_LINE%%$'\t'*}
        LOC_VALUE=${LOC_LINE#*$'\t'}
        LOC_KEY=${LOC_KEY#"${LOC_KEY%%[![:space:]]*}"}
        LOC_KEY=${LOC_KEY%"${LOC_KEY##*[![:space:]]}"}
        LOC_VALUE=${LOC_VALUE#"${LOC_VALUE%%[![:space:]]*}"}
        LOC_VALUE=${LOC_VALUE%"${LOC_VALUE##*[![:space:]]}"}
        if [[ -z $LOC_KEY || -z $LOC_VALUE ]]; then
            LOG_WARNING "Invalid dependency map line: $LOC_LINE"
            continue
        fi

        LOC_DEP_MAP[$LOC_KEY]=$LOC_VALUE
    done < "$LOC_DEP_MAP_FILE"

    LOC_DEP_MAP_READY=1
}

function RESOLVE_DEP() {
    local LOC_DEP=$1

    if [[ $LOC_DEP_MAP_READY -eq 0 ]]; then
        LOAD_DEP_MAP
    fi

    if [[ -n ${LOC_DEP_MAP[$LOC_DEP]+set} ]]; then
        LOC_RESOLVED_DEP=${LOC_DEP_MAP[$LOC_DEP]}
        return
    fi

    if [[ $LOC_DEP != *::* ]]; then
        if [[ -n $LOC_DEP_MAP_FILE ]]; then
            LOG_WARNING "No mapping for dependency '$LOC_DEP' in $LOC_DEP_MAP_FILE, using name as-is"
        else
            LOG_WARNING "No mapping for dependency '$LOC_DEP', using name as-is"
        fi
    fi

    LOC_RESOLVED_DEP=$LOC_DEP
}

mapfile -t LOC_SYSTEM_DEPS < <(SPLIT_LIST "${LOC_SYSTEM[depends]:-}")
mapfile -t LOC_SYSTEM_COMPONENTS < <(SPLIT_LIST "${LOC_SYSTEM[depends-components]:-}")
mapfile -t LOC_SYSTEM_PRECOMPILED < <(SPLIT_LIST "${LOC_SYSTEM[precompiled]:-}")

LOC_MAPPED_SYSTEM_DEPS=()
LOC_CONAN_DEPS=()
for LOC_DEP in "${LOC_SYSTEM_DEPS[@]}"; do
    RESOLVE_DEP "$LOC_DEP"
    LOC_MAPPED_SYSTEM_DEPS+=("$LOC_RESOLVED_DEP")
    if [[ $LOC_DEP != *::* ]]; then
        LOC_CONAN_DEPS+=("$LOC_DEP")
    fi
done

declare -A LOC_SW_MAPPED_DEPS=()
for LOC_SWITCH in "${LOC_SWITCHES[@]}"; do
    if [[ $LOC_SWITCH == tests_enabled ]]; then
        continue
    fi
    mapfile -t LOC_SWITCH_DEPS < <(SPLIT_LIST "${LOC_SW_DEPENDS[$LOC_SWITCH]:-}")
    LOC_SW_MAPPED_DEPS[$LOC_SWITCH]=""
    for LOC_DEP in "${LOC_SWITCH_DEPS[@]}"; do
        RESOLVE_DEP "$LOC_DEP"
        LOC_SW_MAPPED_DEPS[$LOC_SWITCH]+=" $LOC_RESOLVED_DEP"
    done
done

LOC_TMP="CMakeLists.txt.tmp.$$"
trap 'rm -f "$LOC_TMP"' EXIT

{
    if ((${#LOC_MAPPED_SYSTEM_DEPS[@]})); then
        printf 'COMPONENTS_CONFIGURE_COMPONENT(%s "%s"\n' "$LOC_COMPONENT" "$LOC_VERSION"
        for LOC_DEP in "${LOC_MAPPED_SYSTEM_DEPS[@]}"; do
            printf '    %s\n' "$LOC_DEP"
        done
        printf ')\n'
    else
        printf 'COMPONENTS_CONFIGURE_COMPONENT(%s "%s")\n' "$LOC_COMPONENT" "$LOC_VERSION"
    fi

    if ((${#LOC_SYSTEM_PRECOMPILED[@]})); then
        printf 'target_precompile_headers(%s PUBLIC\n' "$LOC_TARGET"
        for LOC_HEADER in "${LOC_SYSTEM_PRECOMPILED[@]}"; do
            printf '    "%s"\n' "$LOC_HEADER"
        done
        printf ')\n'
    fi

    for LOC_SWITCH in "${LOC_SWITCHES[@]}"; do
        if [[ $LOC_SWITCH == tests_enabled || $LOC_SWITCH == qt_enabled ]]; then
            continue
        fi
        if [[ ${LOC_SW_DEFAULT[$LOC_SWITCH]} == none ]]; then
            continue
        fi
        printf 'option(COMPONENTS_SW_%s "" %s)\n' "$LOC_SWITCH" "${LOC_SW_DEFAULT[$LOC_SWITCH]}"
    done

    if ((${#LOC_CONAN_DEPS[@]})); then
        printf 'COMPONENTS_CCR_CONAN_IS_CONFIGURED(COMPONENTS_CONAN_CONFIGURED)\n'
        printf 'if (COMPONENTS_CONAN_CONFIGURED)\n'
        for LOC_DEP in "${LOC_CONAN_DEPS[@]}"; do
            printf '    COMPONENTS_CCR_CONAN_REQUIRE(%s)\n' "$LOC_DEP"
        done
        printf 'endif()\n'
    fi

    for LOC_DEPENDENCY in "${LOC_SYSTEM_COMPONENTS[@]}"; do
        printf 'COMPONENTS_LINK_COMPONENT(%s %s)\n' "$LOC_TARGET" "$LOC_DEPENDENCY"
    done

    for LOC_SWITCH in "${LOC_SWITCHES[@]}"; do
        mapfile -t LOC_SWITCH_COMPONENTS < <(SPLIT_LIST "${LOC_SW_COMPONENTS[$LOC_SWITCH]:-}")
        mapfile -t LOC_SWITCH_SOURCES < <(SPLIT_LIST "${LOC_SW_SOURCES[$LOC_SWITCH]:-}")
        mapfile -t LOC_SWITCH_PRECOMPILED < <(SPLIT_LIST "${LOC_SW_PRECOMPILED[$LOC_SWITCH]:-}")
        mapfile -t LOC_SWITCH_INCLUDES < <(SPLIT_LIST "${LOC_SW_INCLUDES[$LOC_SWITCH]:-}")

        LOC_REMOVE_SOURCES=()
        for LOC_SOURCE in "${LOC_SWITCH_SOURCES[@]}"; do
            if [[ -d $LOC_SOURCE ]]; then
                while IFS= read -r -d '' LOC_SOURCE_FILE; do
                    LOC_SOURCE_FILE=${LOC_SOURCE_FILE#./}
                    LOC_REMOVE_SOURCES+=("$LOC_SOURCE_FILE")
                done < <(find "$LOC_SOURCE" -type f -print0 | sort -z)
            else
                LOC_REMOVE_SOURCES+=("$LOC_SOURCE")
            fi
        done

        LOC_MAPPED_SWITCH_DEPS=()
        if [[ $LOC_SWITCH == tests_enabled ]]; then
            LOC_SWITCH_COMPONENTS=()
            LOC_SWITCH_PRECOMPILED=()
        elif [[ -n ${LOC_SW_MAPPED_DEPS[$LOC_SWITCH]:-} ]]; then
            read -r -a LOC_MAPPED_SWITCH_DEPS <<< "${LOC_SW_MAPPED_DEPS[$LOC_SWITCH]}"
        fi

        LOC_HAS_ENABLED=0
        LOC_HAS_DISABLED=0
        if ((${#LOC_MAPPED_SWITCH_DEPS[@]} || ${#LOC_SWITCH_COMPONENTS[@]} || ${#LOC_SWITCH_PRECOMPILED[@]} || ${#LOC_SWITCH_INCLUDES[@]})); then
            LOC_HAS_ENABLED=1
        fi
        if ((${#LOC_REMOVE_SOURCES[@]})); then
            LOC_HAS_DISABLED=1
        fi
        if ((LOC_HAS_ENABLED == 0 && LOC_HAS_DISABLED == 0)); then
            continue
        fi

        LOC_VARIABLE=$(SWITCH_VARIABLE "$LOC_SWITCH")

        if ((LOC_HAS_ENABLED == 0 && LOC_HAS_DISABLED == 1)); then
            printf 'if (NOT %s)\n' "$LOC_VARIABLE"
        else
            printf 'if (%s)\n' "$LOC_VARIABLE"
        fi

        if ((LOC_HAS_ENABLED == 1)); then
            printf '    target_compile_definitions(%s PRIVATE %s)\n' "$LOC_TARGET" "$LOC_VARIABLE"
            if ((${#LOC_MAPPED_SWITCH_DEPS[@]})); then
                printf '    target_link_libraries(%s PRIVATE' "$LOC_TARGET"
                for LOC_DEP in "${LOC_MAPPED_SWITCH_DEPS[@]}"; do
                    printf ' %s' "$LOC_DEP"
                done
                printf ')\n'
            fi
            for LOC_DEPENDENCY in "${LOC_SWITCH_COMPONENTS[@]}"; do
                printf '    COMPONENTS_LINK_COMPONENT(%s %s)\n' "$LOC_TARGET" "$LOC_DEPENDENCY"
            done
            for LOC_INCLUDE in "${LOC_SWITCH_INCLUDES[@]}"; do
                LOC_INCLUDE=${LOC_INCLUDE#\"}
                LOC_INCLUDE=${LOC_INCLUDE%\"}
                if [[ -n $LOC_INCLUDE ]]; then
                    printf '    target_include_directories(%s PRIVATE "%s")\n' "$LOC_TARGET" "$LOC_INCLUDE"
                fi
            done
            if ((${#LOC_SWITCH_PRECOMPILED[@]})); then
                printf '    target_precompile_headers(%s PUBLIC\n' "$LOC_TARGET"
                for LOC_HEADER in "${LOC_SWITCH_PRECOMPILED[@]}"; do
                    printf '        "%s"\n' "$LOC_HEADER"
                done
                printf '    )\n'
            fi
        fi

        if ((LOC_HAS_DISABLED == 1)); then
            if ((LOC_HAS_ENABLED == 1)); then
                printf 'else()\n'
            fi
            printf '    COMPONENTS_REMOVE_SOURCES(%s\n' "$LOC_TARGET"
            for LOC_SOURCE in "${LOC_REMOVE_SOURCES[@]}"; do
                printf '        "${CMAKE_CURRENT_SOURCE_DIR}/%s"\n' "$LOC_SOURCE"
            done
            printf '    )\n'
        fi

        printf 'endif()\n'
    done

    if [[ -d tests ]]; then
        printf 'COMPONENTS_ADD_COMPONENT_TEST(%s)\n' "$LOC_COMPONENT"
    fi
} > "$LOC_TMP"

mv "$LOC_TMP" CMakeLists.txt
trap - EXIT

LOG_OK "Generated CMakeLists.txt for $LOC_TARGET"
LOG_SEPARATOR
