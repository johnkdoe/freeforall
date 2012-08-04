/*
 
 File: xolawareAdBannerViewController.h
 Abstract: class derived from Apple's BannerViewController class in its SplitViewBanner
 example of ADBannerView containers.
 
 Version: 1.0
 
 Copyright (C) 2012 xolaware LLC
 
 This software is provided with consideration of the following Apple license terms:
 
		File: BannerViewController.h
		Abstract: A container view controller that manages an ADBannerView and a content view controller
		Version: 2.0

		Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
		Inc. ("Apple") in consideration of your agreement to the following
		terms, and your use, installation, modification or redistribution of
		this Apple software constitutes acceptance of these terms.  If you do
		not agree with these terms, please do not use, install, modify or
		redistribute this Apple software.

		In consideration of your agreement to abide by the following terms, and
		subject to these terms, Apple grants you a personal, non-exclusive
		license, under Apple's copyrights in this original Apple software (the
		"Apple Software"), to use, reproduce, modify and redistribute the Apple
		Software, with or without modifications, in source and/or binary forms;
		provided that if you redistribute the Apple Software in its entirety and
		without modifications, you must retain this notice and the following
		text and disclaimers in all such redistributions of the Apple Software.
		Neither the name, trademarks, service marks or logos of Apple Inc. may
		be used to endorse or promote products derived from the Apple Software
		without specific prior written permission from Apple.  Except as
		expressly stated in this notice, no other rights or licenses, express or
		implied, are granted by Apple herein, including but not limited to any
		patent rights that may be infringed by your derivative works or by other
		works in which the Apple Software may be incorporated.

		The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
		MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
		THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
		FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
		OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

		IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
		OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
		SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
		INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
		MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
		AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
		STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
		POSSIBILITY OF SUCH DAMAGE.

		Copyright (C) 2011 Apple Inc. All Rights Reserved.

 As per paragraphs 1 & 2 of the forgoing license terms, xolawareBannerViewController provides
 a modified version of Apple's original BannerViewController.h header implementation.  Being
 modified, the forgoing terms do not strictly require retention of the above text; however, it 
 is provided to establish the chain of copyright from which this source was derived.
 
 xolaware LLC makes no claim as to any endorsement by Apple, and refers to Apple
 in this copyright notice only to establish chain of copyright from which this
 source was derived.

 modifications:
 - renamed xolawareAdBannerViewController to differentiate from the Apple file
 - changed the essential functionality to allow a container to hold the ADBannerView,
   and, when doing so, confine the style of iAds to portrait mode and to the lower right
   portion of the screen.
   - to this end, add xolawareAdBannerViewContainerDataSource
   - change the init routine to initWithDataSource:contentViewController:

*/ 


#import <UIKit/UIKit.h>

@protocol xolawareAdBannerViewContainerDataSource <NSObject>
@property (readonly) NSString* portraitAdImageContainer;
@end

@protocol xolawareAdBannerViewActionRotationWorkaround
@property (readonly, nonatomic) UIBarButtonItem* backupMasterBarButtonItem;
@end

extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;

@interface xolawareAdBannerViewController : UIViewController

- (id)initWithDataSource:(id<xolawareAdBannerViewContainerDataSource>)dataSource
   contentViewController:(UIViewController*)contentController
	backupButtonDelegate:(id<xolawareAdBannerViewActionRotationWorkaround>)buttonDelegate;

@end
