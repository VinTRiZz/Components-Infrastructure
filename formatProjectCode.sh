#! /bin/bash

PRPTC_SCRIPTDIR=$(realpath "$(dirname $0)")

clang-format-19 "--style=file:$PRPTC_SCRIPTDIR/.clang-format" -i $(find "." -iname '*.cpp' -o -iname '*.hpp' -o -iname '*.h')
