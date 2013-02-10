//
//  NSMutableDictionary+Utilities.h
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Utilities)
- (void)updateNestedDictionary:(NSDictionary*)nestedDictionary forKey:(id<NSCopying>)key;
@end
