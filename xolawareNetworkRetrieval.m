//
//  xolawareBackgroundTaskBlock.m
//  voyeur
//
//  Created by me on 2012.06.28.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "xolawareNetworkRetrieval.h"

@interface xolawareNetworkRetrieval ()
{
	xolawareBackgroundTaskBlock backgroundTaskBlockMember;
}

@end

@implementation xolawareNetworkRetrieval

- (xolawareNetworkRetrieval*)initWithTask:(xolawareBackgroundTaskBlock)backgroundTaskBlock
{
	self = [self init];
	if (self)
	{
		backgroundTaskBlockMember = backgroundTaskBlock;
	}
	return self;
}

- (void)execute {
	UIBackgroundTaskIdentifier taskId
	  = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	backgroundTaskBlockMember();
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[UIApplication sharedApplication] endBackgroundTask:taskId];
}

@end
