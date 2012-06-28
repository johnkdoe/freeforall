//
//  xolawareUIResponderWithCoreTelelphonyHandling.m
//  voyeur
//
//  Created by me on 2012.06.27.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareUIResponderWithCoreTelelphonyHandling.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>

NSString* const xolawareCoreTelephonyCall = @"xolawareCoreTelephonyCall";
NSString* const xolawareCoreTelephonyCallDidChangeNotification = @"xolawareCTCallStateDidChangeNotification";

@interface xolawareUIResponderWithCoreTelelphonyHandling ()

@property (strong, nonatomic) CTCallCenter* callCenter;

@end

@implementation xolawareUIResponderWithCoreTelelphonyHandling
@synthesize callCenter = _callCenter;

- (CTCallCenter*)callCenter {
	if (!_callCenter)
	{
		_callCenter = [[CTCallCenter alloc] init];
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
		__weak xolawareUIResponderWithCoreTelelphonyHandling* blockCoreTelphonyHandlingObject = self;
#else
		__block UIResponderWithCoreTelelphonyHandling* blockCoreTelphonyHandlingObject = self; 
#endif
		_callCenter.callEventHandler = ^(CTCall* call) {
			NSDictionary* userInfo
			  = [NSDictionary dictionaryWithObject:call forKey:xolawareCoreTelephonyCall];
			NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
			[defaultCenter postNotificationName:xolawareCoreTelephonyCallDidChangeNotification
										 object:blockCoreTelphonyHandlingObject
									   userInfo:userInfo];
		};
	}
	return _callCenter;
}

- (BOOL)isInCall {
	return nil != self.callCenter.currentCalls;
}

#if __has_feature(objc_arc)

- (void)dealloc 
{
	_callCenter.callEventHandler = nil;
	_callCenter = nil;
}

#else

- (void)dealloc {
	[_callCenter dealloc];
	[super dealloc];
}

#endif

@end
