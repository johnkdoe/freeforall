//
//  xolawareBackground.m
//  xolawareUI
//
//  Created by me on 2012.06.28.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareBackground.h"

@interface xolawareBackground ()
{
	xolawareBackgroundTaskBlock backgroundTaskBlockMember;
}

@end

@implementation xolawareBackground

+ (xolawareBackground*)retriever:(xolawareBackgroundTaskBlock)backgroundTaskBlock {
	return [[xolawareBackground alloc] initWithTask:backgroundTaskBlock];
}

- (xolawareBackground*)initWithTask:(xolawareBackgroundTaskBlock)backgroundTaskBlock
{
	self = [self init];
	if (self)
	{
		backgroundTaskBlockMember = backgroundTaskBlock;
	}
	return self;
}

- (id)getData {
	UIBackgroundTaskIdentifier taskId
	  = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];

		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

		id result = backgroundTaskBlockMember();

		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[[UIApplication sharedApplication] endBackgroundTask:taskId];

	return result;
}

@end
