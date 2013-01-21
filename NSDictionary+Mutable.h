//
//  NSDictionary+Mutable.h
//  xolaware utilities

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import <Foundation/Foundation.h>

@interface NSDictionary (Mutable)
- (NSDictionary*)withObject:(id)object forKey:(id<NSCopying>)key;
@end
