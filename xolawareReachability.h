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
 a modified version of Apple's original Reachability.h class header.  Being
 modified, retention of the forgoing is not strictly required, but provided to
 establish the chain of copyright from which this source was derived.

 xolaware LLC makes no claim as to any endorsement by Apple, and refers to Apple
 in this copyright notice only to establish chain of copyright from which this
 source was derived.
 
 xolaware source code makes use of xolawareReachability.h solely to satisfy
 guidelines set forth by Apple in their "App Store Submission Typs" under the
 sub-heading "Don't Forget to Include Network Error Alerts in Your Code" at URL
 http://developer.apple.com/appstore/resources/submission/tips.html , and which
 refers explicitly to the "Reachability sample application" available at URL
 https://developer.apple.com/library/ios/samplecode/Reachability/index.html to
 members of the iOS Developer Program.

 xolaware makes no claims or reservations on this software, other than that
 any use or derivation of this software should retain this chain of copyright.

 modifications:
 - renamed xolawareReachability to differentiate from the Apple file
 - #import <netinet/in.h> moved to .h to silence warning regarding struct sockaddr_in
 - added simple + (BOOL)connectedToNetwork when not waiting for notification for reachability

*/

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface xolawareReachability: NSObject
{
	BOOL localWiFiRef;
	SCNetworkReachabilityRef reachabilityRef;
}

+ (BOOL)connectedToNetwork;

//reachabilityWithHostName- Use to check the reachability of a particular host name. 
+ (xolawareReachability*)reachabilityWithHostName:(NSString*)hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address. 
+ (xolawareReachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;

//reachabilityForInternetConnection- checks whether the default route is available.  
//  Should be used by applications that do not connect to a particular host
+ (xolawareReachability*)reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
+ (xolawareReachability*)reachabilityForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL)startNotifier;
- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;
//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL)connectionRequired;

@end
