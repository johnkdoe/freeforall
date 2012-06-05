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

 xolaware makes no claims or reservations on this software, other than that
 any use or derivation of this software should retain this chain of copyright.

 modifications:
 - #import <netinet/in.h> moved to .h to silence warning regarding struct sockaddr_in
 - #define kShouldPrintReachabilityFlags set to 0
 - #if kShouldPrintReachabilityFlags moved to streamline code
 
*/

#import <sys/socket.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#import "Reachability.h"

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


@implementation Reachability
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(NSObject*)info isKindOfClass:[Reachability class]],
			  @"info was wrong class in ReachabilityCallback");

	// We're on the main RunLoop, so an NSAutoreleasePool is not necessary,
	// but is added defensively in case someone
	// uses the Reachablity object in a different thread.
	NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];

	Reachability* noteObject = (Reachability*) info;
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
		SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

- (void)dealloc
{
	[self stopNotifier];
	if (reachabilityRef)
		CFRelease(reachabilityRef);

	[super dealloc];
}

+ (Reachability*)reachabilityWithHostName:(NSString*)hostName;
{
	Reachability* retVal = NULL;
	SCNetworkReachabilityRef reachability
	  = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability)
	{
		retVal = [[[self alloc] init] autorelease];
		if(retVal)
		{
			retVal->reachabilityRef = reachability;
			retVal->localWiFiRef = NO;
		}
	}
	return retVal;
}

+ (Reachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
{
	SCNetworkReachabilityRef reachability
	  = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
											   (const struct sockaddr*)hostAddress);
	Reachability* retVal = NULL;
	if (reachability!= NULL)
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

+ (Reachability*)reachabilityForInternetConnection;
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	return [self reachabilityWithAddress: &zeroAddress];
}

+ (Reachability*)reachabilityForLocalWiFi;
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	Reachability* retVal = [self reachabilityWithAddress: &localWifiAddress];
	if (retVal)
		retVal->localWiFiRef = YES;

	return retVal;
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
		if(localWiFiRef)
		{
			retVal = [self localWiFiStatusForFlags: flags];
		}
		else
		{
			retVal = [self networkStatusForFlags: flags];
		}
	}
	return retVal;
}
@end
