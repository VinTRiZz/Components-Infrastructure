# Parses a component manifest into tab-separated records:
# <section><TAB><key><TAB><value>

{
    LOC_LINE = $0
    sub(/\r$/, "", LOC_LINE)
    sub(/^[ \t]+/, "", LOC_LINE)
    sub(/[ \t]+$/, "", LOC_LINE)

    if (LOC_LINE == "" || LOC_LINE ~ /^[;#]/) {
        next
    }

    if (LOC_LINE ~ /^\[.*\]$/) {
        LOC_SECTION = LOC_LINE
        sub(/^\[/, "", LOC_SECTION)
        sub(/\][ \t]*$/, "", LOC_SECTION)
        gsub(/^[ \t]+|[ \t]+$/, "", LOC_SECTION)
        next
    }

    LOC_POSITION = index(LOC_LINE, "=")
    if (LOC_POSITION == 0) {
        next
    }

    LOC_KEY = substr(LOC_LINE, 1, LOC_POSITION - 1)
    LOC_VALUE = substr(LOC_LINE, LOC_POSITION + 1)
    gsub(/^[ \t]+|[ \t]+$/, "", LOC_KEY)
    gsub(/^[ \t]+|[ \t]+$/, "", LOC_VALUE)

    if (LOC_SECTION == "" || LOC_KEY == "") {
        next
    }

    print LOC_SECTION "\t" LOC_KEY "\t" LOC_VALUE
}
