#!/bin/sh
#
# this works based on a combination of recipes found at:
# http://stackoverflow.com/a/10348517/774691
# http://mrox.net/blog/2008/11/16/adding-debug-only-preferences-in-iphone-applications/
# 
# it differs from the stackoverflow answer in the following ways:
# - it assumes the -info.plist is per target
# - it assumes the usual Xcode default of creating a product directory containing the -info.plist
# - it assumes per-target naming of .plist files
# - it uses ${PRODUCT_NAME}/${TARGET_NAME} env-vars from Xcode to achieve this
# - it assumes there's a PSGroupSpecifier "About" containing the version as the first item
# - it assumes the version is already a PSTitleValueSpecifier, and is always first in Root.plist
# - it takes the "outputfile" as an argument, so that it can be invoked as shown in mrox's blog
#
# mrox's blog is helpful to show how to create the build phase that runs this script.
# the script invocation needs to be different in the following ways:
# - it is concerned with version information only, and thus not debug-only
# - it is invoked using Input File $(SRCROOT)/${PRODUCT_NAME}/Resources/Settings.bundle/Root.plist
# - it is invoked using File $(TARGET_BUILD_DIR)/$(FULL_PRODUCT_NAME)/Settings.bundle/Root.plist

set -e

PLISTBUDDYCMD="/usr/libexec/PlistBuddy -c"
SRC_INFO_PLIST=${SRCROOT}/${INFOPLIST_FILE}

CFBSVS=`exec -c ${PLISTBUDDYCMD} "Print :CFBundleShortVersionString" ${SRC_INFO_PLIST}`
CFBV=`exec -c ${PLISTBUDDYCMD} "Print :CFBundleVersion" ${SRC_INFO_PLIST}`
echo exec -c ${PLISTBUDDYCMD} "Set :PreferenceSpecifiers:1:DefaultValue '${CFBSVS} (b${CFBV})'" $1
${PLISTBUDDYCMD} "Set :PreferenceSpecifiers:1:DefaultValue '${CFBSVS} (b${CFBV})'" $1
