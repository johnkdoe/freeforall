#!/bin/sh
#
# this should be run after xolawareAboutInfoVersionInfoInSettings.sh
# and xolawareProductSettingsShortVersion-from-git.sh

echo "-- ${INFOPLIST_FILE} git commit & tag Install Script --"

SCRIPT_VERSION=`/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${INFOPLIST_FILE}`
SCRIPT_BUILD_NUMBER=`/usr/libexec/Plistbuddy -c 'Print :CFBundleVersion' ${INFOPLIST_FILE}`
if [ `git status --porcelain ${SCRIPT_INFO_PLIST}|wc -l` -gt 0 ]; then
	echo git commit -m '"'version ${SCRIPT_VERSION} build ${SCRIPT_BUILD_NUMBER}'"' ${INFOPLIST_FILE}
	git commit -m "version ${SCRIPT_VERSION} build ${SCRIPT_BUILD_NUMBER}" ${INFOPLIST_FILE}
fi
echo git tag -f ${SCRIPT_VERSION}
git tag -f -F /dev/null ${SCRIPT_VERSION}
