//
//  xolawareSystemSettingsUserDefaultsSynchronizer.m
//  xolawareUI
//
//  Created me kb on 2012.11.26.
//	inspired by post on net by Greg Haygood
//	http://greghaygood.com/2009/03/09/updating-nsuserdefaults-from-settingsbundle

#import "xolawareSystemSettingsUserDefaultsSynchronizer.h"

@implementation xolawareSystemSettingsUserDefaultsSynchronizer

+ (NSArray*)settingsBundleSettingsArray {
	NSString* settingsPath = [NSBundle.mainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle* settingsBundle = [NSBundle bundleWithPath:settingsPath];
	NSString* rootPlist = [settingsBundle pathForResource:@"Root" ofType:@"plist"];
	NSDictionary* settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:rootPlist];
	return [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
}

+ (void)establishInitialUserDefaults {
	NSLog(@"user defaults may not have been loaded from Settings.bundle ... doing that now ...");

	NSArray* settings = [self settingsBundleSettingsArray];

	// Loop through the array
	for (NSDictionary* item in settings)
	{
		NSString* keyValue = [item objectForKey:@"Key"];
		if (keyValue)
		{
			// Get the default value specified in the plist file.
			id defaultValue = [item objectForKey:@"DefaultValue"];
			if (defaultValue)
				[self.standardUserDefaults setObject:defaultValue forKey:keyValue];
		}
	}
	[self.standardUserDefaults synchronize];
}

+ (BOOL)establishVersionAndRequireInitialSync {
	NSArray* settings = [self settingsBundleSettingsArray];
	NSString* settingsBundleVersion = [settings[1] objectForKey:@"DefaultValue"];
	NSString* userDefaultsVersion = [self.standardUserDefaults valueForKey:@"about_version"];
	if ([userDefaultsVersion isEqualToString:settingsBundleVersion])
		return NO;

	[self.standardUserDefaults setObject:settingsBundleVersion forKey:@"about_version"];
	[self.standardUserDefaults synchronize];
	return nil == userDefaultsVersion;
}

#pragma mark - public class method implementation

+ (void)establishInternalSettings {
	BOOL neverPreviouslyInitialized = [self establishVersionAndRequireInitialSync];
	if (neverPreviouslyInitialized)
		[self establishInitialUserDefaults];
}

@end
