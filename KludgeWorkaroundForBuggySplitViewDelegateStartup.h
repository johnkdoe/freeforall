//
//  KludgeWorkaroundForBuggySplitViewDelegateStartup.h
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
//	the interface is simply the name that should appear in the bar-button
//	in the navigation button for the detailViewController.

#import <UIKit/UIKit.h>

@interface KludgeWorkaroundForBuggySplitViewDelegateStartup
  : UIViewController <UISplitViewControllerDelegate>
@property (readonly, nonatomic) NSString* kludgeWorkaroundMasterViewButtonStartupTitle;
@end
