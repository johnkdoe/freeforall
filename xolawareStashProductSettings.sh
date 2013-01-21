#!/bin/sh
#
# should be run prior to the Copy Bundle Resources step
# and prior to any version information modifier scripts

INFOPLIST_GIT_PATH=${PROJECT}/`basename ${INFOPLIST_FILE}`
echo "-- Temp Hold ${INFOPLIST_GIT_PATH} Script --"

set -e

# a fallback in case the user has made changes to the file
if [ `git status --porcelain ${INFOPLIST_GIT_PATH} ]|wc -l` -gt 0 ]; then
	echo cp -p ${INFOPLIST_GIT_PATH} ${TARGET_TEMP_DIR}
	cp -p ${INFOPLIST_GIT_PATH} ${TARGET_TEMP_DIR}
fi
