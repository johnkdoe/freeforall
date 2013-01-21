//
//  NSDictionary+NSUserDefaults.m
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import "NSDictionary+NSUserDefaults.h"
#import "NSArray+NSUserDefaults.h"

@implementation NSDictionary (NSUserDefaults)

- (NSDictionary*)deepCleanForDefaults {
	NSMutableArray* keys = self.allKeys.mutableCopy;
	NSMutableArray* objects = [NSMutableArray arrayWithCapacity:keys.count];
	for (NSString* key in self)
	{
		id obj = [self objectForKey:key];
		if ([obj isKindOfClass:[NSNull class]])
		{
			[keys removeObject:key];
			continue;
		}
		if ([obj isKindOfClass:[self class]] || [obj isKindOfClass:[NSArray class]])
			[objects addObject:[obj deepCleanForDefaults]];
		else
			[objects addObject:obj];
	}
	return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}


@end
