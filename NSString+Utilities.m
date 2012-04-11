//
//  NSString+Utilities.m
//  FlikrTop
//
//  Created by me on 2012.04.09.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (BOOL)isNonEmpty
{
	return ![self isEqualToString:@""];
}

@end
