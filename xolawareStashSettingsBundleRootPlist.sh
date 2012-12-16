#!/bin/sh
#
# should be run prior to the Copy Bundle Resources step
# and prior to any version information modifier scripts

echo '-- Temp Hold Settings.bundle/Root.plist Script --'

ROOT_PLIST=${PROJECT}/Resources/Settings.bundle/Root.plist

set -e

# a fallback in case the user has made changes to the file
if [ `git status --porcelain ${ROOT_PLIST} ]|wc -l` -gt 0 ]; then
	echo cp -p ${ROOT_PLIST} ${TARGET_TEMP_DIR}
	cp -p ${ROOT_PLIST} ${TARGET_TEMP_DIR}
fi
