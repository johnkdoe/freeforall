//
//  NSArray+Mutable.m
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import "NSArray+Mutable.h"

@implementation NSArray (Mutable)

- (NSArray*)arrayByRemovingObject:(id)anObject {
	NSMutableArray* mutableSelf = self.mutableCopy;
	[mutableSelf removeObject:anObject];
	return mutableSelf.copy;
}

@end
