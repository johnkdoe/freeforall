//
//  TabBarInSplitViewMasterViewController.m
//  xolawareUI - freeforall
//
//  Created by kb on 2012.11.02.

#import "xolawareOpenSourceCopyright.h"

#import "TabBarInSplitViewMasterViewController.h"

#import "UISplitViewController+MasterDetailUtilities.h"

@implementation TabBarInSplitViewMasterViewController

#pragma mark - UIViewController @property implementation overrides

- (NSString*)title {
	if (self.visibleViewController.title)
		return self.visibleViewController.title;
	if (self.selectedViewController.title)
		return self.selectedViewController.title;
	return [[[self.viewControllers objectAtIndex:0] tabBarItem] title];
}

#pragma mark - public method implementations

- (UIViewController*)visibleViewController {
	return ((UINavigationController*)self.selectedViewController).topViewController;
}

#pragma mark - UISplitViewControllerDelegate protocol implementation
#pragma mark @optional

- (BOOL) splitViewController:(UISplitViewController*)svc
	shouldHideViewController:(UIViewController*)vc
			   inOrientation:(UIInterfaceOrientation)orientation
{
	if (UIInterfaceOrientationIsLandscape(orientation))
		return NO;
	if (![self.selectedViewController respondsToSelector:@selector(topViewController)])
		return YES;
	if (![self.visibleViewController respondsToSelector:@selector(tableView)])
		return YES;
	return !((UITableViewController*)self.visibleViewController).tableView.isEditing;
}

- (void)splitViewController:(UISplitViewController*)splitController
	 willHideViewController:(UIViewController*)viewController
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem
	   forPopoverController:(UIPopoverController *)popoverController
{
	UINavigationController* detailVC = (id)splitController.detailUIViewController;
	[detailVC.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	detailVC.navigationItem.leftBarButtonItem.title = self.splitViewController.masterTitle;
}

// the following is a workaround for bug at startup whereby the back button flashes up in
// landscape mode (at least on iOS simulator for iPad); the root cause is that
//	1) splitViewController:willHideViewController:withBarButtonItem:forPopoverController:
//	2) splitViewController:willShowViewController:invalidatingBarButtonItem:
// both get called when only (2) should be called. an attempt was made to use the normal check
// of (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])), but that always
// returns YES for (1) and NO for (2).  another workaround was to try to not set the bar-button
// title until later, but no sequence would guarantee a button in portrait combined with no
// flashing in landscape.
//
// in the end, while the real problem is that the button never should have been shown so that
// hiding it would e a no-op, the cosmetic part of the problem is that there are two animations,
// the showing of the button and then the hiding of it.  so, the cosmetic solution is to simply
// make certain not to show both animations.  fortunately, iOS animations works in such a way
// that performing the same operation on a UI element without animation after an operation that
// performed animation suppresses the first animation.  thus, by turning off animation on the
// second hide but force hiding the button, it suppresses the animation from (1) above.  and by
// using the counter and just incrementing it, we effectively get 4-billion rotations before
// the button is not animated when switching to landscape.  ... good enough!!!

static NSUInteger KLUDGE_ANIMATION_WORKAROUND = 0;


- (void)splitViewController:(UISplitViewController*)splitController
	 willShowViewController:(UIViewController*)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	// Called when the view is shown again in the split view, invalidating the button and popover controller.
	UINavigationController* detailVC = (id)splitController.detailUIViewController;
	[detailVC.navigationItem setLeftBarButtonItem:nil animated:KLUDGE_ANIMATION_WORKAROUND++];
}

@end
