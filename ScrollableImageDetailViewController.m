//
//  ScrollableImageDetailViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "ScrollableImageDetailViewController.h"
#import "xolawareUIResponderWithCoreTelelphonyHandling.h"
#import <CoreTelephony/CTCall.h>

#import "FlipsideViewController.h"

#import "NSString+Utilities.h"
#import "UINavigationController+NestedNavigationController.h"
#import "UISplitViewController+MasterDetailUtilities.h"
#import "UITabBarController+HideTabBar.h"					// thank you Carlos Oliva

#import "xolawareReachability.h"

@interface ScrollableImageDetailViewController ()
	<UIPopoverControllerDelegate, FlipsideViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tripleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *fourTapGesture;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *tap1ThenHoldGesture;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *tap2ThenHoldGesture;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *blindsImageView;
@property (weak, nonatomic) UIImageView* nestedImageView;
@property (weak, nonatomic) IBOutlet UILabel *networkUnavailableLabel;

@property (readonly, nonatomic) NSString* titleForNoImage;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property BOOL barsHidden;
@property BOOL ignoreExceptionallyUglyStatusBarWillChangeFrameNotificationKludgeHackWorkaround;
@property (readonly) CGSize recommendedZoomScales;

@property (strong, nonatomic) xolawareReachability* internetReachability;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *tripleTap3FingerThenHoldGesture;

@end

#pragma mark -

@implementation ScrollableImageDetailViewController

@synthesize image = _image;
@synthesize originatingURL = _originatingURL;
@synthesize nestedNavControllerHandler = _nestedNavControllerHandler;

@synthesize singleTapGesture = _singleTapGesture;
@synthesize doubleTapGesture = _doubleTapGesture;
@synthesize tripleTapGesture = _tripleTapGesture;
@synthesize fourTapGesture = _fourTapGesture;
@synthesize tap1ThenHoldGesture = _tapThenHoldGesture;
@synthesize tap2ThenHoldGesture = _tap2ThenHoldGesture;

@synthesize flipsidePopoverController = _flipsidePopoverController;

@synthesize scrollView = _scrollView;
@synthesize blindsImageView = _blindsImageView;
@synthesize nestedImageView = _nestedImageView;
@synthesize networkUnavailableLabel = _networkUnavailableLabel;

@synthesize titleForNoImage = _titleForNoImage;

@synthesize internetReachability = _internetReachability;

@synthesize tripleTap3FingerThenHoldGesture = _tripleTap3FingerThenHoldGesture;

@synthesize ignoreExceptionallyUglyStatusBarWillChangeFrameNotificationKludgeHackWorkaround = _ignoreExceptionallyUglyStatusBarWillChangeFrameNotificationKludgeHackWorkaround;

- (void)setImage:(UIImage*)uiImage
{
	if (self.barsHidden)
		[self setBarsHidden:NO animated:NO];
	_image = uiImage;
	if (!_image)
		self.navigationItem.title = self.titleForNoImage;
	self.navigationItem.rightBarButtonItem.enabled = _image ? YES : NO;
	if (self.scrollView)			// this method can be invoked before viewDidLoad on iPhone
		[self nestImageInScrollView];
}

- (BOOL)barsHidden {
	return self.navigationController.navigationBarHidden;
}

- (void)setBarsHidden:(BOOL)hidden {
	[self setBarsHidden:hidden animated:YES];
}

- (xolawareReachability*)internetReachability {
	if (!_internetReachability)
		_internetReachability = [xolawareReachability reachabilityForInternetConnection];
	return _internetReachability;
}

- (CGSize)recommendedZoomScales
{
	CGFloat widthScale = self.scrollView.bounds.size.width / self.image.size.width;
	CGFloat heightScale = self.scrollView.bounds.size.height / self.image.size.height;
	
	// just reset the zoom scales; leave center and everything else where possible
	self.scrollView.minimumZoomScale = MIN(1.0, MIN(widthScale, heightScale));
	self.scrollView.maximumZoomScale = 4.0;
	
	return CGSizeMake(widthScale, heightScale);
}

- (CGFloat)recommendedZoomScale {
	CGSize recommendedZoom = self.recommendedZoomScales;
	return MAX(recommendedZoom.width, recommendedZoom.height);
}

#pragma mark - ScrollableImageDetailViewController public implementation

- (void)setImageTitle:(NSString*)imageTitle {
	// setting self.title here occurs too early for phone.
	self.navigationItem.title = NSLocalizedString(imageTitle, nil);
}

#pragma mark - ScrollableImageDetailViewController private implementation

- (void)callDidChange:(NSNotification*)notification {
	assert(notification.name == xolawareCoreTelephonyCallDidChangeNotification);
#if DEBUG
	NSDictionary* userInfo = notification.userInfo;
	NSLog(@"%@ userInfo %@", xolawareCoreTelephonyCallDidChangeNotification, userInfo);
	CTCall* call = [userInfo objectForKey:xolawareCoreTelephonyCall];
	NSLog(@"%@ id = %@, state = %@", xolawareCoreTelephonyCall, call.callID, call.callState);
#endif
	if (!self.barsHidden)
		return;

	UIApplication* uiApp = [UIApplication sharedApplication];
	xolawareUIResponderWithCoreTelelphonyHandling* xolawareTelephonyHandler = notification.object;
	BOOL animate = (BOOL)self.view.window;
	if (uiApp.isStatusBarHidden && xolawareTelephonyHandler.isInCall)
	{
#if DEBUG
		NSLog(@"calls all calls done");
#endif
		[uiApp setStatusBarHidden:NO withAnimation:[self statusBarAnimation:animate]];
	}
	else if (!uiApp.isStatusBarHidden && !xolawareTelephonyHandler.isInCall)
	{
#if DEBUG
		NSLog(@"calls exist");
#endif
		[uiApp setStatusBarHidden:YES withAnimation:[self statusBarAnimation:animate]];
	}
}

- (void)debugLog:(NSString*)caller
{
//	NSLog(@"[%@]z=%g,svb={%g,%g,%g,%g},svf={%g,%g,%g,%g},nivb={%g,%g,%g,%g},nivf={%g,%g,%g,%g}",
//		  caller, self.scrollView.zoomScale,
//		  self.scrollView.bounds.origin.x, self.scrollView.bounds.origin.y,
//		  self.scrollView.bounds.size.width, self.scrollView.bounds.size.height,
//		  self.scrollView.frame.origin.x, self.scrollView.frame.origin.y,
//		  self.scrollView.frame.size.width, self.scrollView.frame.size.height,
//		  self.nestedImageView.bounds.origin.x, self.nestedImageView.bounds.origin.y,
//		  self.nestedImageView.bounds.size.width, self.nestedImageView.bounds.size.height,
//		  self.nestedImageView.bounds.origin.x, self.nestedImageView.bounds.origin.y,
//		  self.nestedImageView.bounds.size.width, self.nestedImageView.bounds.size.height
//		  );
}

- (void)establishGestureDependencies
{
	[self.tripleTapGesture requireGestureRecognizerToFail:self.fourTapGesture];
	[self.doubleTapGesture requireGestureRecognizerToFail:self.tripleTapGesture];
	[self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
	
	[self.doubleTapGesture requireGestureRecognizerToFail:self.tap2ThenHoldGesture];
	[self.singleTapGesture requireGestureRecognizerToFail:self.tap1ThenHoldGesture];
}

- (void)hideBlinds:(CGFloat)duration
{
	BOOL isPad = UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom];
	CGFloat delay = isPad ? 0.333 : 0.4;
	CGRect hiddenBlindsRect = CGRectMake(0, 0, self.blindsImageView.frame.size.width, 0);

	[UIView animateWithDuration:duration+delay delay:delay options:UIViewAnimationCurveEaseInOut
					 animations:^{ self.blindsImageView.frame = hiddenBlindsRect; }
					 completion:^(BOOL finished) {
						 [NSThread sleepForTimeInterval:duration+0.11];
						 self.blindsImageView.hidden = YES;
					 }
	 ];
}

typedef void (^completionBlock)(BOOL);

- (void)nestImageInScrollViewButDeleteOldImageFirstIfNecessary
{
	if (_nestedImageView && [self.scrollView.subviews containsObject:_nestedImageView])
	{
		self.scrollView.zoomScale = 1;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
			[self nestImageInScrollViewFadeInNewImage];
		else
			[UIView animateWithDuration:0.075 delay:0
								options:UIViewAnimationOptionTransitionCrossDissolve
							 animations:^{ _nestedImageView.alpha = 0; }
							 completion:^(BOOL oldImageDeleted) {
								 if (oldImageDeleted)
									 [_nestedImageView removeFromSuperview];
								 [self nestImageInScrollViewFadeInNewImage];		
							 }];
	}
	else
		[self nestImageInScrollViewFadeInNewImage];	
}

- (void)nestImageInScrollViewFadeInNewImage {
	if (self.image)
	{
		// the image may have come from cache, and so there may be
		// no network availability, but we'll live with that for now				
		self.networkUnavailableLabel.hidden = YES;
		[self.internetReachability stopNotifier];
		
		self.scrollView.contentSize = self.image.size;
		UIImageView* imageView = [[UIImageView alloc] initWithImage:self.image];
		BOOL isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
		if (isPad)
			imageView.alpha = 0;
		[self.scrollView addSubview:imageView];
		_nestedImageView = self.scrollView.subviews.lastObject;
		self.scrollView.zoomScale = self.recommendedZoomScale;
		
		// must come after setZoomScale
		self.scrollView.contentOffset = CGPointZero;
		if (isPad)
			[UIView animateWithDuration:0.075 delay:0
								options:UIViewAnimationOptionTransitionCrossDissolve
							 animations:^{ _nestedImageView.alpha = 1; }
							 completion:^(BOOL finished){ [self hideBlinds:0.1]; }];
		else
			[self hideBlinds:0.22];
	}
	else	// no image; may be due to no network availability
	{
		BOOL netLabelHidden = self.networkUnavailableLabel.hidden;
		if ([xolawareReachability connectedToNetwork] != netLabelHidden)
		{
			if (netLabelHidden)
				[self.internetReachability startNotifier];
			else
				[self.internetReachability stopNotifier];
			self.networkUnavailableLabel.hidden = !netLabelHidden;
		}
	}
	
}

- (void)nestImageInScrollView
{
	completionBlock deleteOldImageThenNestNewImageInScrollView
	  = ^(BOOL finished){ [self nestImageInScrollViewButDeleteOldImageFirstIfNecessary]; };
	if (self.blindsImageView.isHidden)
	{
		self.blindsImageView.hidden = NO;
		CGRect visibleBlindsRect = [self visibleBlindsRect];
		[UIView animateWithDuration:0.22 delay:0.0 options:UIViewAnimationCurveEaseOut
						 animations:^{ self.blindsImageView.frame = visibleBlindsRect; }
						 completion:deleteOldImageThenNestNewImageInScrollView];
	}
	else
	{
		// this seems a bit kludgy, but putting this animation in even at 0,0 causes it to work!
		[UIView animateWithDuration:0.0 delay:0.001 options:UIViewAnimationCurveLinear
						 animations:^{ self.blindsImageView.frame = [self visibleBlindsRect]; }
						 completion:deleteOldImageThenNestNewImageInScrollView];
	}
}

- (void)reachabilityChanged:(NSNotification*)note
{
#if DEBUG
	xolawareReachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[xolawareReachability class]]);
#endif

	// setImage: -> nestImageInScrollView => stops notifier + hides networkUnavailableIndicator
	self.image = nil;
}

- (CGRect)rectForStatusBarFrame:(CGRect)f {
	return [self.view convertRect:[self.view.window convertRect:f fromWindow:nil] fromView:nil];
}

- (void)removeNotificationObservers {
	NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self
								  name:kReachabilityChangedNotification 
								object:nil];
	[notificationCenter removeObserver:self
								  name:xolawareCoreTelephonyCallDidChangeNotification
								object:nil];
	[notificationCenter removeObserver:self
								  name:UIApplicationWillChangeStatusBarFrameNotification
								object:nil];
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		[self setTabBarHidden:hidden animated:animated];
        [self setStatusBarHidden:hidden animated:animated];
	}
//	else 
//	{
//		[self setSplitViewMasterViewControllerHidden:hidden animated:animated];
//	}

	// must be performed after hiding/showing of statusBar
	[self.navigationController setNavigationBarHidden:hidden animated:animated];

}

/*
	the math below all works, but when done, there's a black space in the master area
 
- (void)setSplitViewMasterViewControllerHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (self.splitViewController
		&& UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
	{
		UIView* masterView = self.splitViewController.selectedTabBarNavigationController.view;	// 0x07954da0 UILayoutContainerView		  {  0,0; 320 748}
		UIView* detailView = self.splitViewController.detailUIViewController.view;				// 0x0794a910 UIView					  {  0,0; 703 748}
		UIView* detailViewViewControllerWrapperView = detailView.superview;						// 0x0794add0 UIViewControllerWrapperView {  0,0; 703 748}
		UIView* navigationTransitionView = detailViewViewControllerWrapperView.superview;		// 0x079547d0 UINavigationTransitionView  {  0,0; 703 748}
		UIView* detailViewLayout = navigationTransitionView.superview;							// 0x07978da0 UILayoutContainerView		  {321,0; 703 748}

		UIView* masterViewControllerWrapperView = masterView.superview;
		UIView* masterTransitionView = masterViewControllerWrapperView.superview;
		UIView* masterViewLayout = masterTransitionView.superview;

		assert(masterViewLayout.superview == detailViewLayout.superview);
		for (UIView* view in masterViewLayout.superview.subviews)
			if (view == masterViewLayout || view == detailViewLayout)
				continue;
			else
				[view removeFromSuperview];

		CGRect masterLayoutFrame = masterView.frame;
		CGRect detailLayoutFrame = detailViewLayout.frame;

		CGFloat width = masterLayoutFrame.size.width - masterLayoutFrame.origin.x;
		if (hidden)
		{
			masterLayoutFrame.origin.x = -width;
			detailLayoutFrame.size.width += detailLayoutFrame.origin.x;
			detailLayoutFrame.origin.x = 0;
		}
		else
		{
			detailLayoutFrame.size.width -= width;
			masterLayoutFrame.origin.x = 0;
			detailLayoutFrame.origin.x = width + 1;
		}
		CGRect innerFrame
		  = CGRectMake(0, 0, detailLayoutFrame.size.width, detailLayoutFrame.size.height);
		[UIView animateWithDuration:animated ? 0.3 : 0
						 animations:^{
							 masterTransitionView.superview.frame = masterLayoutFrame;
							 masterTransitionView.superview.hidden = hidden;
							 navigationTransitionView.superview.frame = detailLayoutFrame;
							 detailViewViewControllerWrapperView.superview.frame = innerFrame;
							 detailView.superview.frame = innerFrame;
							 detailView.frame = innerFrame;
						 }
		 ];
	}
}*/

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    // status bar first, because otherwise the navigation bar is in the wrong place
    UIApplication* app = [UIApplication sharedApplication];
    UIInterfaceOrientation originalOrientation = app.statusBarOrientation;
    BOOL performStatusBarAnimation;
    if (UIInterfaceOrientationIsLandscape(originalOrientation))
    {
        _ignoreExceptionallyUglyStatusBarWillChangeFrameNotificationKludgeHackWorkaround = YES;
        [app setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        CGRect portraitFrame = app.statusBarFrame;
        [app setStatusBarOrientation:originalOrientation animated:NO];
        _ignoreExceptionallyUglyStatusBarWillChangeFrameNotificationKludgeHackWorkaround = NO;

        performStatusBarAnimation = (40 != portraitFrame.size.height);
    }
    else
        performStatusBarAnimation = (40 != app.statusBarFrame.size.height);
    
    if (performStatusBarAnimation)
        [app setStatusBarHidden:hidden withAnimation:[self statusBarAnimation:animated]];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    id parent = self.navigationController.parentViewController;
    if ([parent respondsToSelector:@selector(isTabBarHidden)]
        && hidden != [parent isTabBarHidden]
        && [parent respondsToSelector:@selector(setTabBarHidden:animated:)])
        [parent setTabBarHidden:hidden animated:animated];
}

/*
- (void)showBlinds
{
	self.blindsImageView.hidden = NO;
	CGRect visibleBlindsRect = [self visibleBlindsRect];
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut
	animations:^{ self.blindsImageView.frame = visibleBlindsRect; }
	completion:^(BOOL finished) { [self hideBlinds]; } ];
}
*/

- (UIStatusBarAnimation)statusBarAnimation:(BOOL)animated {
	return animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone;
}

//- (void)statusBarWillChangeOrientation:(NSNotification*)notification {
//	assert(notification.name == UIApplicationWillChangeStatusBarOrientationNotification);
//	UIApplication* app = notification.object;
//	if (self.barsHidden && UIInterfaceOrientationIsPortrait(app.statusBarOrientation)
//		&& (40 == app.statusBarFrame.size.height))
//	{
//		NSNumber* userInfoNewOrientation
//		  = [notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
//		UIInterfaceOrientation newOrientation = [userInfoNewOrientation unsignedIntValue];
//		if (UIInterfaceOrientationIsLandscape(newOrientation))
//		{
//			BOOL nowHideStatusBar = ;
//			UIStatusBarAnimation animation
//			  = self.view.window ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone;
//			[notification.object setStatusBarHidden:nowHideStatusBar withAnimation:animation];
//		}
//	}
//}

- (void)statusBarWillChangeFrame:(NSNotification*)notification {
	if (_ignoreExceptionallyUglyStatusBarWillChangeFrameNotificationKludgeHackWorkaround)return;

	assert(notification.name == UIApplicationWillChangeStatusBarFrameNotification);
	if (self.barsHidden)
	{
		NSValue* userInfoCGRect
		  = [notification.userInfo objectForKey:UIApplicationStatusBarFrameUserInfoKey];
		CGRect properAppStatusBarFrame, appStatusBarFrame = [notification.object statusBarFrame];
		CGRect properNewStatusBarFrame, newStatusBarFrame = [userInfoCGRect CGRectValue];
		BOOL orientationChange = NO;
		if (UIInterfaceOrientationIsLandscape([[notification object] statusBarOrientation]))
			properAppStatusBarFrame = [self rectForStatusBarFrame:appStatusBarFrame];
		else
			properAppStatusBarFrame = appStatusBarFrame;
		if (newStatusBarFrame.size.width == properAppStatusBarFrame.size.width)
		{
			properNewStatusBarFrame = newStatusBarFrame;
		}
		else
		{
			properNewStatusBarFrame = [self rectForStatusBarFrame:newStatusBarFrame];
			orientationChange
			  = properNewStatusBarFrame.size.width != properAppStatusBarFrame.size.width;
		}

		if (!orientationChange)	// i.e. not an orientation change
		{
			BOOL hidden = properNewStatusBarFrame.size.height <= 20;
			UIStatusBarAnimation sbAnimation = [self statusBarAnimation:(BOOL)self.view.window];
			[notification.object setStatusBarHidden:hidden withAnimation:sbAnimation];
		}
	}
}

- (CGRect)visibleBlindsRect {
	return CGRectMake(0, 0, self.blindsImageView.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UIViewController life cycle overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
	_titleForNoImage
	  = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
	self.scrollView.delegate = self;
	if (self.image)						// in iPhone segue, image will get set before load
		[self nestImageInScrollView];
	[self establishGestureDependencies];

	if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom])
	{
		self.title = _titleForNoImage;
		[self resetSplitViewBarButtonTitle];
	}
	else
	{
		self.title = self.navigationItem.title;
		[self.navigationController.navigationBar
			setTitleVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
		[self.navigationController.navigationBar
			setTitleVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsLandscapePhone];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
													animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom])
	{
		NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(statusBarWillChangeFrame:)
								   name:UIApplicationWillChangeStatusBarFrameNotification
								 object:nil];
		[notificationCenter addObserver:self selector:@selector(callDidChange:)
								   name:xolawareCoreTelephonyCallDidChangeNotification
								 object:nil];
		[notificationCenter addObserver:self selector:@selector(reachabilityChanged:)
								   name:kReachabilityChangedNotification
								 object:nil];
	}

	if (self.blindsImageView && !_blindsImageView.isHidden && _nestedImageView && self.image)
		[self hideBlinds:0.4444];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (self.barsHidden)
		[self setBarsHidden:NO animated:animated];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		[self removeNotificationObservers];

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		[self.navigationController popToEligibleViewController:self.nestedNavControllerHandler
													  animated:NO];

	[super viewDidDisappear:animated];
}

- (void)viewWillUnload
{
	if (self.barsHidden)
		[self setBarsHidden:NO animated:NO];
	
	[super viewWillUnload];
}

- (void)viewDidUnload
{
	[self.internetReachability stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kReachabilityChangedNotification
												  object:nil];

	self.internetReachability = nil;
	self.nestedImageView = nil;
	[self setScrollView:nil];						// automatically inserted by Xcode
	[self setDoubleTapGesture:nil];					// automatically inserted by Xcode
	[self setTripleTapGesture:nil];					// automatically inserted by Xcode
	[self setSingleTapGesture:nil];					// automatically isnerted by Xcode
	[self setBlindsImageView:nil];					// automatically inserted by Xcode
	[self setNetworkUnavailableLabel:nil];			// automatically inserted by Xcode
	[self setTripleTap3FingerThenHoldGesture:nil];	// automatically inserted by Xcode
	[self setTap1ThenHoldGesture:nil];				// automatically inserted by Xcode
	[self setFourTapGesture:nil];					// automatically inserted by Xcode
	[self setTap2ThenHoldGesture:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
// more animation here than i have time to get right; so just turning it off
// (specifically, the blinds image is too long to start when rotating to portrait
// and too short to start when rotating to landscape)
//	if (self.nestedImageView)
//		[self hideBlinds:0.2];

	// need all these values for zooming as done after the orientation
	float zoomScale = self.scrollView.zoomScale;
	float oldMinZoom = self.scrollView.minimumZoomScale;

	[self recommendedZoomScales];

	if (zoomScale == oldMinZoom || zoomScale < self.scrollView.minimumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	else if (zoomScale > self.scrollView.maximumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];

	if (self.blindsImageView.isHidden)
	{
		CGRect hiddenBlindsViewFrame = self.blindsImageView.frame;
		hiddenBlindsViewFrame.size.height = 0;
		self.blindsImageView.frame = hiddenBlindsViewFrame;
	}
}
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{
// more animation here than i have time to get right; so just turning it off
// (specifically, the blinds image is too long to start when rotating to portrait
// and too short to start when rotating to landscape)
	if (self.nestedImageView)
		[self showBlinds];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"scrollableImageDetailInfo"])
	{
		[segue.destinationViewController setFlipsideViewControllerDelegate:self];
		NSURL* flipsideURL;
		if (self.originatingURL)
		{
			if ([xolawareReachability connectedToNetwork])
				flipsideURL = self.originatingURL;
			else
				flipsideURL = @"networkDown".urlForMainBundleResourceHTML;
		}
		else if (self.image)
			flipsideURL = @"missingOriginatingURL".urlForMainBundleResourceHTML;
		[segue.destinationViewController setOriginatingURL:flipsideURL];

		if ([segue respondsToSelector:@selector(popoverController)])
		{
			self.flipsidePopoverController = [(id)segue popoverController];
			self.flipsidePopoverController.delegate = self;
		}
		if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom])
			self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

#pragma mark - gesture recognizers

- (IBAction)singleTap:(UITapGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		// only adjust the zoom if the old picture used to fill the frame,
		// but (a) will be too small when hiding bars,
		// or  (b) was an exact match when exposing bars
		CGSize previousRecommendedZoom = self.recommendedZoomScales;
		BOOL hidden = self.barsHidden = !self.barsHidden;
		CGSize recommendedZoom = self.recommendedZoomScales;
		if (hidden)
		{
			if (self.scrollView.zoomScale >= previousRecommendedZoom.height
				&& self.scrollView.zoomScale < recommendedZoom.height)
				[self.scrollView setZoomScale:recommendedZoom.height animated:YES];
		}
		else	// bars now exposed
		{
			if (self.scrollView.zoomScale == previousRecommendedZoom.height)
				[self.scrollView setZoomScale:recommendedZoom.height animated:YES];
		}
	}
}

- (IBAction)doubleTap:(UITapGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		// this should cause it to bounce if it ends up greater than the max
		[self.scrollView setZoomScale:self.scrollView.zoomScale*1.25 animated:YES];
		[self.scrollView setNeedsDisplay];
	}
}

- (IBAction)tripleTap:(UIGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		[self.scrollView setZoomScale:1 animated:YES];
		[self.scrollView setNeedsDisplay];
	}	
}

- (IBAction)ignoreMoreThan3Taps:(id)sender {}

- (IBAction)tap1ThenHold:(UILongPressGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateBegan)
	{
		[self.scrollView setZoomScale:self.recommendedZoomScale animated:YES];
		[self.scrollView setNeedsDisplay];
	}	
}

- (IBAction)tap2ThenHold:(UILongPressGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateBegan)
	{
		[self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
		[self.scrollView setNeedsDisplay];
	}	
}

- (IBAction)tripleTap3FingerThenHold:(UILongPressGestureRecognizer *)sender
{
#if DEBUG
	UIApplication* app = [UIApplication sharedApplication];
	CGRect appStatusBarFrame = app.statusBarFrame;
	if (UIInterfaceOrientationIsPortrait(app.statusBarOrientation))
		appStatusBarFrame.size.height = 40;
	else
		appStatusBarFrame.size.width = 20;
	NSValue* statusBarFrameRect = [NSValue valueWithCGRect:appStatusBarFrame];
	NSDictionary* userInfo
	  = [NSDictionary dictionaryWithObject:statusBarFrameRect
									forKey:UIApplicationStatusBarFrameUserInfoKey];
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
	[notifyCenter postNotificationName:UIApplicationWillChangeStatusBarFrameNotification
								object:app
							  userInfo:userInfo];
#endif
}

#pragma mark - FlipsideViewControllerDelegate implementation

- (void)flipsideViewControllerDidFinish:(FlipsideViewController*)controller
{
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom])
	{
//		[self dismissModalViewControllerAnimated:YES];
		[self dismissViewControllerAnimated:YES completion:nil];
    }
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;	// turn info button back on
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

#pragma mark - SplitViewTitle protocol implementation

- (void)resetSplitViewBarButtonTitle {
	self.navigationItem.leftBarButtonItem.title = self.splitViewController.masterTitle;
}

#pragma mark - UIPopoverControllerDelegate protocol implementation

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.flipsidePopoverController = nil;
}

#pragma mark - UIScrollViewDelegate protocol implementation
#pragma mark @optional

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView {
	return self.nestedImageView;
}

@end
