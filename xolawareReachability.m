/*
 
 File: xolawareReachability.h
 Abstract: class derived from Apple's Reachability example
 
 Version: 1.0
 
 Copyright (C) 2012 xolaware LLC

 This software is provided with consideration of the following Apple license terms:

	"In consideration of your agreement to abide by the following terms, and subject
	 to these terms, Apple grans you a personal, non-exclusive license, under
	 Apple's copyrights in this original Apple software (the "Apple Software"), to
	 use, reproduce, modify and redistribute the Apple Software, with or without
	 modifications, in source and/or binary forms; provided that if you redistribute
	 the Apple Software in its entirety and without modifications, you must retain
	 this notice and the following text and disclaimers in all such redistributions
	 of the Apple Software.

	 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
	 to endorse or promote products derived from the Apple Software without specific
	 prior written permission from Apple.  Except as expressly stated in this notice,
	 no other rights or licenses, express or implied, are granted by Apple herin,
	 including but not limited to any patent rights that may be infringed by your
	 derivative works or by other works in which the Apple Software may be
	 incorporated.

	 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
	 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
	 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
	 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
	 COMBINATION WITH YOUR PRODUCTS.

	 IN NO EVENT SHALL APPLE BE HELD LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
	 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
	 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
	 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
	 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
	 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

	 Copyright (C) 2010 Apple Inc. All Rights Reserved."

 As per paragraph 1 of the forgoing license terms, xolawareReachability provides
 a modified version of Apple's original Reachability.m class header.  Being
 modified, retention of the forgoing is not strictly required, but provided to
 establish the chain of copyright from which this source was derived.

 xolaware LLC makes no claim as to any endorsement by Apple, and refers to Apple
 in this copyright notice only to establish chain of copyright from which this
 source was derived.
 
 xolaware source code makes use of xolawareReachability.m solely to satisfy
 guidelines set forth by Apple in their "App Store Submission Typs" under the
 sub-heading "Don't Forget to Include Network Error Alerts in Your Code" at URL
 http://developer.apple.com/appstore/resources/submission/tips.html , and which
 refers explicitly to the "Reachability sample application" available at URL
 https://developer.apple.com/library/ios/samplecode/Reachability/index.html to
 members of the iOS Developer Program.

 xolaware makes no claims or reservations on this software, expect to require that any direct
 use or derivation of this file should retain this chain of copyright and the chain of
 modifications below:
 - renamed xolawareReachability to differentiate from the Apple file
 - #import <netinet/in.h> moved to .h to silence warning regarding struct sockaddr_in
 - don't #import <netinet/in6.h> to suppress preprocessor issue in that file: see RFC2553
 - #define kShouldPrintReachabilityFlags set to 0
 - #if kShouldPrintReachabilityFlags moved to streamline code
 - added simple + (BOOL)connectedToNetwork when not waiting for notification for reachability
 - refactored code in several members functions to new member - (struct sockaddr_in)zeroAddress
 - added simple + (void)alertNetworkUnavailable when simplest message to user required

*/

#import <sys/socket.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#import "xolawareReachability.h"

#define kShouldPrintReachabilityFlags 0

#if kShouldPrintReachabilityFlags
static void PrintReachabilityFlags(SCNetworkReachabilityFlags    flags, const char* comment)
{
	
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
			(flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
			(flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
			
			(flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
			(flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
			(flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
			(flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
			comment
			);
}
#endif


@implementation xolawareReachability
static void ReachabilityCallback(SCNetworkReachabilityRef target,
								 SCNetworkReachabilityFlags flags, void* info)
{
	#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(NSObject*)info isKindOfClass:[xolawareReachability class]],
			  @"info was wrong class in ReachabilityCallback");

	// We're on the main RunLoop, so an NSAutoreleasePool is not necessary,
	// but is added defensively in case someone
	// uses the Reachablity object in a different thread.

	// automatic objc-arc as is default in Xcode 4.3 + iOS 5 can be suppressed
	// with -fno-objc-arc for this file in the CompileSource tab of the target Build Phases
	NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];

	xolawareReachability* noteObject = (xolawareReachability*) info;
	// Post a notification to notify the client that the network reachability changed.
	[[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification
														object:noteObject];
	[myPool release];
}

- (BOOL)startNotifier
{
	SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
	return (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context)
			&& SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(),
														kCFRunLoopDefaultMode));
}

- (void)stopNotifier
{
	if (reachabilityRef)
		SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(),
												   kCFRunLoopDefaultMode);
}

- (void)dealloc
{
	[self stopNotifier];
	if (reachabilityRef)
		CFRelease(reachabilityRef);

	[super dealloc];
}

+ (UIAlertView*)alertNetworkUnavailable:(id<UIAlertViewDelegate>)delegate {
	UIAlertView* _alertView
	  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"network unavailable", nil)
								   message:NSLocalizedString(@"unable to connect", nil)
								  delegate:delegate
						 cancelButtonTitle:NSLocalizedString(@"try later", nil)
						 otherButtonTitles:nil];

	[_alertView show];
	return [_alertView autorelease];
}

+ (xolawareReachability*)reachabilityWithHostName:(NSString*)hostName;
{
	xolawareReachability* retVal = NULL;
	SCNetworkReachabilityRef reachability
	  = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability)
	{
		retVal = [[[self alloc] init] autorelease];
		if (retVal)
		{
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (struct sockaddr_in)zeroAddress
{
	struct sockaddr_in _zeroAddress;
	bzero(&_zeroAddress, sizeof(_zeroAddress));
	_zeroAddress.sin_len = sizeof(_zeroAddress);
	_zeroAddress.sin_family = AF_INET;
	return _zeroAddress;
}

+ (BOOL)connectedToNetwork
{
	const struct sockaddr_in zeroAddress = self.zeroAddress;
	SCNetworkReachabilityRef zeroRouteReachability
	  = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&zeroAddress);
	SCNetworkReachabilityFlags flags;

	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(zeroRouteReachability, &flags);
	CFRelease(zeroRouteReachability);
	if (!didRetrieveFlags)
		return NO;

	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;

	return isReachable && !needsConnection;
}

+ (xolawareReachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
{
	SCNetworkReachabilityRef reachability
	  = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
											   (const struct sockaddr*)hostAddress);
	xolawareReachability* retVal = NULL;
	if (reachability != NULL)
	{
		retVal = [[[self alloc] init] autorelease];
		if (retVal)
		{
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (xolawareReachability*)reachabilityForInternetConnection;{
	const struct sockaddr_in zeroAddress = self.zeroAddress;
	return [self reachabilityWithAddress:&zeroAddress];
}

+ (xolawareReachability*)reachabilityForLocalWiFi;
{
	struct sockaddr_in localWifiAddress = self.zeroAddress;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	xolawareReachability* retVal = [self reachabilityWithAddress:&localWifiAddress];
	if (retVal)
		retVal->localWiFiRef = YES;

	return retVal;
}

+ (NSError*)canonicalNetworkUnreachableError {
	return [NSError errorWithDomain:@"reachability" code:kCFURLErrorNotConnectedToInternet
						   userInfo:@{@"error" : NSLocalizedString(@"network offline", nil)}];

}

#pragma mark Network Flag Handling

- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{

#if kShouldPrintReachabilityFlags
	PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
#endif

	BOOL retVal = NotReachable;
	if ((flags & kSCNetworkReachabilityFlagsReachable)
		&& (flags & kSCNetworkReachabilityFlagsIsDirect))
	{
		retVal = ReachableViaWiFi;	
	}
	return retVal;
}

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	
#if kShouldPrintReachabilityFlags
	PrintReachabilityFlags(flags, "networkStatusForFlags");
#endif

	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// if target host is not reachable
		return NotReachable;
	}

	BOOL retVal = NotReachable;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = ReachableViaWiFi;
	}
	
	
	if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0)
		|| ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
		// ... and the connection is on-demand (or on-traffic) if the
		//     calling application is using the CFSocketStream or higher APIs

		if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
			// ... and no [user] intervention is needed
			retVal = ReachableViaWiFi;
	}
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = ReachableViaWWAN;
	}
	return retVal;
}

- (BOOL)connectionRequired
{
	NSAssert(reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);

	return NO;
}

- (NetworkStatus) currentReachabilityStatus
{
	NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
	NetworkStatus retVal = NotReachable;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
	{
		if (localWiFiRef)
			retVal = [self localWiFiStatusForFlags: flags];
		else
			retVal = [self networkStatusForFlags: flags];
	}
	return retVal;
}

@end
