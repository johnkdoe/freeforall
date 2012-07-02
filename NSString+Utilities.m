//
//  NSString+Utilities.m
//  xolaware utilities
//
//  Created by me on 2012.04.09.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (BOOL)isNonEmpty {
	return ![self isEqualToString:@""];
}

- (NSURL*)urlForMainBundleResourceHTML {
	NSString* resPath = [[NSBundle mainBundle] pathForResource:self ofType:@"html"];
	if (resPath)
		return [NSURL fileURLWithPath:resPath];
	return nil;
}

@end
