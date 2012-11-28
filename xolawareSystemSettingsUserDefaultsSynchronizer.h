//
//  xolawareSystemSettingsUserDefaultsSynchronizer.h
//  xolawareUI
//
//  Created by kb on 2012.11.26.
//	inspired by post on net by Greg Haygood
//	http://greghaygood.com/2009/03/09/updating-nsuserdefaults-from-settingsbundle
//
//	Greg Haygood provided the knowledge about the Settings.bundle not getting synced with
//	User Defaults until after the first time a user inspects user-defaults.
//
//	This synchronizer aims to use his algorithm (provided at the URL listed above) to properly
//	do an initial sync of user defaults without having to check the settings first, but to also
//	properly update the version, which we've populated with xolawareGenerateAboutInfoInSettings.sh
//
//	this synchronizer assumes the Settings.bundle is set up as follows:
//
//	- array item 0 is a PSGroupSpecifier (About)
//	- array item 1 is a PSTitleValueSpecifier with a key "about_version"

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <Foundation/Foundation.h>

@interface xolawareSystemSettingsUserDefaultsSynchronizer : NSUserDefaults
+ (void)establishInternalSettings;
@end
