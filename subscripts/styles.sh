#! /bin/bash

# Uses clang-format on a project source directories

LOC_STYLES_CLANGFILE="$LOC_MAIN_BASEDIR/data/util/.clang-format"

while IFS= read -r line; do
    if (! test -e "$LOC_MAIN_BASEDIR/"); then

    fi

    echo "$line"
done < "file.txt"

clang-format-19 "--style=file:$LOC_STYLES_CLANGFILE" -i $(find "$PRPTC_SCRIPTDIR/../../Libraries" "$LOC_MAIN_BASEDIR/../../App" -iname '*.cpp' -o -iname '*.hpp' -o -iname '*.h')
