#!/bin/sh
#
# this should be run after xolawareStashSettingsBundleRootPlist.sh
# and prior to xolawareAboutInfoVersionInfoInSettings.sh

echo "-- Auto-Increment ${INFOPLIST_FILE} Build Version Install Script --"

PLISTBUDDYCMD="/usr/libexec/PlistBuddy -c"

CFBV=$(${PLISTBUDDYCMD} "Print :CFBundleVersion" ${PRODUCT_SETTINGS_PATH})
if [[ "${CFBV}" == "" ]]; then
	echo "No build number in ${PRODUCT_SETTINGS_PATH}"
    exit 2
fi

CFBV=$(expr $CFBV + 1)

set -e
echo ${PLISTBUDDYCMD} "Set :CFBundleVersion $CFBV" "${PRODUCT_SETTINGS_PATH}"
${PLISTBUDDYCMD} "Set :CFBundleVersion $CFBV" "${PRODUCT_SETTINGS_PATH}"
