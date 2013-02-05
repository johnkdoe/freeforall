//
//  NSArray+Mutable.h
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import <Foundation/Foundation.h>

@interface NSArray (Mutable)
- (NSArray*)arrayByRemovingObject:(id)anObject;
- (NSArray*)arrayWithoutObjectAtIndex:(NSUInteger)index;
@end
