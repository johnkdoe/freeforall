//
//  NSMutableDictionary+Utilities.m
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import "NSMutableDictionary+Utilities.h"

@implementation NSMutableDictionary (Utilities)

- (void)updateNestedDictionary:(NSDictionary*)nestedDictionary forKey:(id<NSCopying>)key {
	if (nestedDictionary.count)		// accounts for both nil and for dictionary w/no entries
		[self setObject:nestedDictionary forKey:key];
	else
		[self removeObjectForKey:key];
}

@end
