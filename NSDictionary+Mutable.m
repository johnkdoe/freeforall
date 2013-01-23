//
//  NSDictionary+Mutable.m
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import "NSDictionary+Mutable.h"

@implementation NSDictionary (Mutable)

- (NSDictionary*)withObject:(id)object forKey:(id<NSCopying>)key {
	NSMutableDictionary* mutableDictionary = self.mutableCopy;
	[mutableDictionary setObject:object forKey:key];
	return mutableDictionary.copy;
}

- (NSDictionary*)withoutObjectWithKey:(id<NSCopying>)key {
	NSMutableDictionary* mutableDictionary = self.mutableCopy;
	[mutableDictionary removeObjectForKey:key];
	return mutableDictionary.copy;
}

@end
