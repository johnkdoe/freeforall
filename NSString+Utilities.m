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

- (NSString*)stringByLocalizingThenAppending:(NSString*)stringToAppend {
	return [NSLocalizedString(self, nil) stringByAppendingString:stringToAppend];
}

- (NSURL*)urlForMainBundleResourceHTML {
	NSString* resPath = [[NSBundle mainBundle] pathForResource:self ofType:@"html"];
	if (resPath)
		return [NSURL fileURLWithPath:resPath];
	return nil;
}

- (BOOL)hasCharacterInSet:(NSCharacterSet*)charSet {
	return NSNotFound != [self rangeOfCharacterFromSet:charSet].location;
}

- (BOOL)hasNewline {
	return [self hasCharacterInSet:[NSCharacterSet newlineCharacterSet]];
}

- (BOOL)hasWhitespace {
	return [self hasCharacterInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)hasWhitespaceOrNewline {
	return [self hasCharacterInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
