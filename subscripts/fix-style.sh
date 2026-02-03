#! /bin/bash

# Uses clang-format on a project source directories

LOC_STYLES_CLANGFILE="$LOC_MAIN_BASEDIR/data/util/.clang-format"

LOG_SEPARATOR
LOG_INFO "Starting style check..."

while IFS= read -r line; do
    LOC_checkdir="$MAIN_PROJECT_ROOTDIR/$line"
    if (! test -e "$LOC_checkdir"); then
        LOG_WARNING "Directory \"$line\" not found, skipped"
        continue
    fi

    LOG_INFO "Fixing styles in: $line"
    clang-format-19 "--style=file:$LOC_STYLES_CLANGFILE" -i $(find "$LOC_checkdir" -iname '*.cpp' -o -iname '*.hpp' -o -iname '*.h')
    LOG_OK "Complete"
done < "$LOC_SOURCES"

LOG_OK "Style fix completed"
LOG_SEPARATOR
