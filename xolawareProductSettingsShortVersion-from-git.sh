#!/bin/sh
#
# this should be run after xolawareStashSettingsBundleRootPlist.sh
# and prior to xolawareAboutInfoVersionInfoInSettings.sh

echo '-- Get Product Settings Short Version String from git describe --'

PLISTBUDDYCMD="/usr/libexec/PlistBuddy -c"

CFBVS=`git describe|awk '{split($0,a,"-"); print a[1]}'`
CFBVSI=`git describe|awk '{split($0,a,"-"); print a[2]}'`
if [[ "$CFBVSI" != "" ]]; then
	CFBVS=${CFBVS}.${CFBVSI}
fi

set -e
echo ${PLISTBUDDYCMD} "Set :CFBundleShortVersionString $CFBVS" "${PRODUCT_SETTINGS_PATH}"
${PLISTBUDDYCMD} "Set :CFBundleShortVersionString $CFBVS" "${PRODUCT_SETTINGS_PATH}"
