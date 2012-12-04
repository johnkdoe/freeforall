#!/bin/sh
#
# this should be invoked after xolawareStashInfoAndRootPlist.sh,
# xolawareIncrementProductSettingsBuildNumber.sh and 
# xolawareProductSettingsShortVersion-from-git.sh, and before
# the regular Copy Bundle Resources Build Phase

echo '-- Auto-Insert Version Info In System Settings Script --'

PLISTBUDDYCMD="/usr/libexec/PlistBuddy -c"
ROOT_PLIST=${PROJECT_DIR}/${PROJECT}/Resources/Settings.bundle/Root.plist

CFBSVS=`exec -c ${PLISTBUDDYCMD} "Print :CFBundleShortVersionString" ${PRODUCT_SETTINGS_PATH}`
CFBV=`exec -c ${PLISTBUDDYCMD} "Print :CFBundleVersion" ${PRODUCT_SETTINGS_PATH}`

set -e
echo ${PLISTBUDDYCMD} "Set :PreferenceSpecifiers:1:DefaultValue '${CFBSVS} (b${CFBV})'" ${ROOT_PLIST}
${PLISTBUDDYCMD} "Set :PreferenceSpecifiers:1:DefaultValue '${CFBSVS} (b${CFBV})'" ${ROOT_PLIST}
