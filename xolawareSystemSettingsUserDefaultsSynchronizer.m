//
//  xolawareSystemSettingsUserDefaultsSynchronizer.m
//  xolawareUI
//
//  Created me kb on 2012.11.26.
//	inspired by post on net by Greg Haygood
//	http://greghaygood.com/2009/03/09/updating-nsuserdefaults-from-settingsbundle

#import "xolawareSystemSettingsUserDefaultsSynchronizer.h"

@implementation xolawareSystemSettingsUserDefaultsSynchronizer

+ (void)doIt {
	NSLog(@"user defaults may not have been loaded from Settings.bundle ... doing that now ...");

	NSString* settingsPath = [NSBundle.mainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle* settingsBundle = [NSBundle bundleWithPath:settingsPath];
	NSString* rootPlist = [settingsBundle pathForResource:@"Root" ofType:@"plist"];

	// Get the Preferences Array from the dictionary
	NSDictionary* settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:rootPlist];

	// Loop through the array
	for (NSDictionary* item in [settingsDictionary objectForKey:@"PreferenceSpecifiers"])
	{
		NSString* keyValue = [item objectForKey:@"Key"];
		if (keyValue)
		{
			// Get the default value specified in the plist file.
			id defaultValue = [item objectForKey:@"DefaultValue"];
			if (defaultValue)
				[[NSUserDefaults standardUserDefaults] setObject:defaultValue forKey:keyValue];
		}
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
