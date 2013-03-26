#!/bin/sh
#
# this should be run after xolawareAboutInfoVersionInfoInSettings.sh
# and xolawareProductSettingsShortVersion-from-git.sh

if [[ "$CONFIGURATION" == "Debug" ]]; then

	INFOPLIST_BASENAME=`basename ${INFOPLIST_FILE}`
	INFOPLIST_GIT_PATH=${PROJECT}/${INFOPLIST_BASENAME}
	echo "-- ${INFOPLIST_GIT_PATH} Restore Script --"

	# first, see if it was stashed earlier due to uncommitted changes
	if [ -e ${TARGET_TEMP_DIR}/${INFOPLIST_BASENAME} ]; then
		echo mv ${TARGET_TEMP_DIR}/${INFOPLIST_BASENAME} ${PROJECT}
		mv ${TARGET_TEMP_DIR}/${INFOPLIST_BASENAME} ${PROJECT}
	elif [ `git status --porcelain ${SCRIPT_INFO_PLIST}|wc -l` -gt 0 ]; then
		if ( ls /private/tmp/????.??.??-??????-${INFOPLIST_BASENAME} > /dev/null 2>&1 ); then
			echo removing previous temporary copies of ${INFOPLIST_BASENAME}
			rm /private/tmp/????.??.??-??????-${INFOPLIST_BASENAME}
		fi
		INFOPLIST_DATE_PREFIX=`date +"%Y.%m.%d-%H%M%S"`
		echo moving ${INFOPLIST_GIT_PATH} to /private/tmp/${INFOPLIST_DATE_PREFIX}-${INFOPLIST_BASENAME} in case you did not want to revert it
		cp -p ${INFOPLIST_GIT_PATH} /private/tmp/${INFOPLIST_DATE_PREFIX}-${INFOPLIST_BASENAME}
		echo git checkout -- ${INFOPLIST_GIT_PATH}
		git checkout -- ${INFOPLIST_GIT_PATH}
	else
		echo ${INFOPLIST_PATH} restore unnecessary
	fi

fi
