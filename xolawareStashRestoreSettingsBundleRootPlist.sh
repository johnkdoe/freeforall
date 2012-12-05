#!/bin/sh
#
# should be run as the last script in Build Phases, after the Copy Bundle Resources Phase

echo "-- Manual Restore $INFOPLIST_FILE Script --"

ROOT_PLIST=${PROJECT}/Resources/Settings.bundle/Root.plist

set -e

# first, see if it was stashed earlier due to uncommitted changes
if [ -e ${TARGET_TEMP_DIR}/Root.plist ]; then
	echo mv ${TARGET_TEMP_DIR}/Root.plist ${ROOT_PLIST}
	mv ${TARGET_TEMP_DIR}/Root.plist ${ROOT_PLIST}

# the better option when available: restore to the pristine state
elif [ `git status --porcelain ${ROOT_PLIST}|wc -l` -gt 0 ]; then
	echo git checkout -- ${ROOT_PLIST}
	git checkout -- ${ROOT_PLIST}
fi

