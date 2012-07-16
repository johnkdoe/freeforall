/*
 
 File: xolawareAdBannerViewController.m
 Abstract: class derived from Apple's BannerViewController class in its SplitViewBanner
 example of ADBannerView containers.
 
 Version: 1.0
 
 Copyright (C) 2012 xolaware LLC
 
 This software is provided with consideration of the following Apple license terms:
 
		File: BannerViewController.m
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
 a modified version of Apple's original BannerViewController.m class implementation.  Being
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
   - create @property bannerContainerImage and bannerContainerImageView to hold the image
   - change loadView and viewDidLayoutSubviews to account for the banner container
 - fix a problem where rotating while the iAd has left the app
   - add @property orientationWhenLeavingForAd
   - set orientationWhenLeavingForAd in bannerViewActionShouldBegin:willLeave:
   - compare the extant orientation against orientationUponBannerViewAction in
     bannerViewActionDidFinish:, and request a layout update if necessary.
 - comment out BannerViewActionWillBegin/BannerViewActionDidFinish notification names for now
 - also comment out the notifications that get generated
*/ 

#import "xolawareAdBannerViewController.h"
#import <iAd/iAd.h>
#import "UISplitViewController+MasterDetailUtilities.h"

//NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
//NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface xolawareAdBannerViewController () <ADBannerViewDelegate>

@property (strong, nonatomic)	UIImage* bannerContainerImage;
@property (readonly, nonatomic) UIImageView* bannerContainerImageView;
@property (strong, nonatomic)	ADBannerView* bannerView;
@property (weak, nonatomic)		id<xolawareAdBannerViewActionRotationWorkaround> buttonDelegate;
@property (strong, nonatomic)	UIViewController* contentController;
@property (weak, nonatomic)		id<xolawareAdBannerViewContainerDataSource> dataSource;

@property BOOL orientationUponBannerViewAction;

@end

@implementation xolawareAdBannerViewController

@synthesize bannerContainerImage = _bannerContainerImage;
@synthesize bannerContainerImageView = _bannerContainerImageView;
@synthesize bannerView = _bannerView;
@synthesize buttonDelegate = _buttonDelegate;
@synthesize contentController = _contentController;
@synthesize dataSource = _dataSource;
@synthesize orientationUponBannerViewAction = _orientationWhenLeavingForAd;

- (id)initWithDataSource:(id<xolawareAdBannerViewContainerDataSource>)dataSource
   contentViewController:(UIViewController*)contentController
	backupButtonDelegate:(id<xolawareAdBannerViewActionRotationWorkaround>)buttonDelegate
{
    self = [super init];
    if (self != nil) {
        _bannerView = [[ADBannerView alloc] init];
        _bannerView.delegate = self;
		_bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		_buttonDelegate = buttonDelegate;
        _contentController = contentController;
		_dataSource = dataSource;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:self.contentController.view];
	if ([self.dataSource respondsToSelector:@selector(portraitAdImageContainer)])
	{
		_bannerContainerImage = [UIImage imageNamed:_dataSource.portraitAdImageContainer];

		// if you're seeing this, the image you are attempting to use is not an appropriate size
		assert(self.bannerView.frame.size.height + 6 == _bannerContainerImage.size.height);

		_bannerContainerImageView = [[UIImageView alloc] initWithImage:_bannerContainerImage];
		_bannerContainerImageView.userInteractionEnabled = YES;
		[self.view addSubview:self.bannerContainerImageView];
		[self.bannerContainerImageView addSubview:self.bannerView];
	}
	else
	{
		[self.view addSubview:self.bannerView];
	}

	[_contentController removeFromParentViewController];
    [self addChildViewController:_contentController];
    [_contentController didMoveToParentViewController:self];
}

- (void)viewDidLayoutSubviews {
	CGRect viewBounds = self.view.bounds;
	CGRect bannerFrame = _bannerView.frame;
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
	if (_bannerContainerImageView)
	{
		CGRect containerFrame = _bannerContainerImageView.frame;
		containerFrame.size.width = viewBounds.size.width;
		if (isPortrait && !_bannerView.isBannerLoaded)
		{
			_bannerContainerImageView.image = nil;
			containerFrame.size.height = 0;
		}
		else if (_bannerContainerImageView.image != _bannerContainerImage)
		{
			_bannerContainerImageView.image = _bannerContainerImage;
			containerFrame.size.height = _bannerContainerImage.size.height;
		}
		containerFrame.origin.y = viewBounds.size.height - containerFrame.size.height;
		_bannerContainerImageView.frame = containerFrame;
		viewBounds.size.height -= containerFrame.size.height;

		bannerFrame.origin.x = containerFrame.size.width - bannerFrame.size.width;
		if (!isPortrait)
			bannerFrame.origin.x -= 3;
		bannerFrame.origin.y = _bannerView.isBannerLoaded ? 3 : 0;	// just a little frame
		_bannerView.alpha = _bannerView.isBannerLoaded ? 1 : 0;
	}
	else 
	{
		if (isPortrait)
			_bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		else
			_bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		if (_bannerView.isBannerLoaded)
			viewBounds.size.height -= _bannerView.frame.size.height;
		bannerFrame.origin.y = viewBounds.size.height;
	}
	_contentController.view.frame = viewBounds;
	_bannerView.frame = bannerFrame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [UIView animateWithDuration:0.4 animations:^{ 
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	}];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	if (!banner.isBannerLoaded)
		[UIView animateWithDuration:0.2 animations:^{
			[self.view setNeedsLayout];
			[self.view layoutIfNeeded];
		}];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView*)banner willLeaveApplication:(BOOL)willLeave {
//	[[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin
//														object:self];
	self.orientationUponBannerViewAction = self.contentController.interfaceOrientation;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
//	[[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish
//														object:self];
	if (self.contentController.interfaceOrientation != self.orientationUponBannerViewAction
		&& [self.contentController isKindOfClass:[UISplitViewController class]])
	{
		UISplitViewController* splitVC = (UISplitViewController*)self.contentController;
		if (UIInterfaceOrientationIsPortrait(self.contentController.interfaceOrientation))
			splitVC.masterBarButtonItem = self.buttonDelegate.backupMasterBarButtonItem;
		else
			splitVC.masterBarButtonItem = nil;
		[splitVC.view setNeedsLayout];
		[splitVC.view layoutIfNeeded];
	}
}

@end
