//
//  NSArray+NSUserDefaults.m
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import "NSArray+NSUserDefaults.h"

@implementation NSArray (NSUserDefaults)

- (NSArray*)deepCleanForDefaults {
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
	for (id obj in self)
	{
		if ([obj isKindOfClass:[NSNull class]])
			[result addObject:[NSData data]];	// sort of punting … will be empty NSData
		else if ([obj isKindOfClass:[self class]] || [obj isKindOfClass:[NSDictionary class]])
			[result addObject:[obj deepCleanForDefaults]];
		else
			[result addObject:obj];
	}
	return result.copy;
}

@end
