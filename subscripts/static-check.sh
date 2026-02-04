#! /bin/bash

LOG_SEPARATOR
LOG_INFO "Starting static check..."

LOC_includeline=""
while IFS= read -r dirname; do
    LOC_includeline="$LOC_includeline $MAIN_PROJECT_ROOTDIR/$dirname"
done < "$LOC_INCLUDES"

LOC_sourcesline=""
while IFS= read -r dirname; do
    LOC_sourcesline="$LOC_sourcesline $MAIN_PROJECT_ROOTDIR/$dirname"
done < "$LOC_SOURCES"

LOG_DEBUG "Checking files: $LOC_sourcesline"
LOG_DEBUG "Includes:       $LOC_includeline"
eval cppcheck --enable=all --std=c++20 --platform=unix64 --suppress=missingInclude $LOC_sourcesline $LOC_includeline &> "$LOC_LOGS_DIR/static_check_$LOG_START_TIMESTAMP.log"

if [ ! $? ]; then
    LOG_ERROR "Static check failed"
    exit 1
fi

LOG_OK "Static check completed"
LOG_SEPARATOR
