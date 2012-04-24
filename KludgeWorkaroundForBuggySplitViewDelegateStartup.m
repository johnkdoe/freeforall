//
//  KludgeWorkaroundForBuggySplitViewDelegateStartup.m
//  theGRID
//
//  Created by me on 2012.04.23.

#include "xolawareOpenSourceCopyright.h"

//	without a check on orientation, when the app is started in landscape mode, 
//		splitViewController:willHideViewController:withBarButtonItem:forPopoverController:
//	is getting called in portrait mode first, followed by call to
//		splitViewController:willShowViewController:invalidatingBarButtonItem: .
//	unfortunately, this causes the bar-button item with the name of the controller
//	to appear briefly, and then disappear.
//
//	even more unfortunately, the initial attempt at a workaround failed in
//		splitViewController:willHideViewController:withBarButtonItem:forPopoverController:
//	specifically, the following check was attempted.
//
//		if (!barButtonItem.title && UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
//
//	however, at least when running in the iOS simulator for iPad, it doesn't recognize that
//	it is starting in portrait mode, and so the device-based check fails
//
//	... thus xolaware has created the kludge.
//
//	the implementation is as follows:
//	1)	in splitViewController:willHideViewController:withBarButtonItem:forPopoverController: ,
//		if the barButton doesn't yet have a title, simply stash a reference to it.
//	2)	in viewDidAppear: , if we appear to be in landscape mode based on the view height
//		being at least 15% greater than the width, then assume portrait mode,
//		and force the button stashed in the weak reference into the navigitionItem.leftBarButton
//	3)	in splitViewController:willShowViewController:invalidatingBarButtonItem: , if passed
//		a button that doesn't yet have a title, assign it so when later set, it's correct
//
//	implementors that want to do more should just [super call] these.


#import "KludgeWorkaroundForBuggySplitViewDelegateStartup.h"

@interface KludgeWorkaroundForBuggySplitViewDelegateStartup ()
@property (weak, nonatomic) UIBarButtonItem* startupBarButtionItemWeakReference;
@end

@implementation KludgeWorkaroundForBuggySplitViewDelegateStartup
@synthesize kludgeWorkaroundMasterViewButtonStartupTitle;
@synthesize startupBarButtionItemWeakReference = _startupBarButtionItemWeakReference;

- (UIBarButtonItem*)startupBarButtionItemWeakReference {
	return _startupBarButtionItemWeakReference;
}

- (NSString*)kludgeWorkaroundMasterViewButtonTitle {
	return NSLocalizedString(@"Master", @"");
}

#pragma mark - UIViewController life cycle overrides

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (!self.startupBarButtionItemWeakReference
		|| self.view.frame.size.width*1.15 > self.view.frame.size.height)
		return;
	
	self.startupBarButtionItemWeakReference.title
	  = self.kludgeWorkaroundMasterViewButtonStartupTitle;
	self.navigationItem.leftBarButtonItem = self.startupBarButtionItemWeakReference;
	self.startupBarButtionItemWeakReference = nil;
}

#pragma mark - 

- (void)splitViewController:(UISplitViewController*)splitController
	 willHideViewController:(UIViewController*)viewController
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem
	   forPopoverController:(UIPopoverController*)popoverController
{
	if (self.view)	// no need to call this this early
		if (barButtonItem.title)
			[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
		else
			self.startupBarButtionItemWeakReference = barButtonItem;
}

- (void)splitViewController:(UISplitViewController*)splitController
	 willShowViewController:(UIViewController*)viewController
  invalidatingBarButtonItem:(UIBarButtonItem*)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
	if (!barButtonItem.title)
		barButtonItem.title = self.kludgeWorkaroundMasterViewButtonStartupTitle;
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

@end
