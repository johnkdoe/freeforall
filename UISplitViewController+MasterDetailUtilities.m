//
//  UISplitViewController+MasterDetailUtilities.m
//  xolawareUI
//
//  Created by me on 2012.04.22.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "UISplitViewController+MasterDetailUtilities.h"

@implementation UISplitViewController (MasterDetailUtilities)

- (UIViewController*)topViewController:(id)controller
{
	if ([controller respondsToSelector:@selector(topViewController)])
		return [controller topViewController];

	return nil;
}

- (UIViewController*)masterUIViewController {
	return [self topViewController:[self.viewControllers objectAtIndex:0]];
}

- (UIViewController<UISplitViewControllerDelegate>*)detailUIViewController {
	id controller = [self topViewController:[self.viewControllers lastObject]]; 
	assert([controller isKindOfClass:[UIViewController class]]
		   && [controller conformsToProtocol:@protocol(UISplitViewControllerDelegate)]);
	return (UIViewController<UISplitViewControllerDelegate>*)controller;
}

- (UITabBarController*)masterTabBarController {
	id controller = [self.viewControllers objectAtIndex:0];
	if ([controller isKindOfClass:[UITabBarController class]])
		return controller;
	return nil;
}

- (UINavigationController*)selectedTabBarNavigationController {
	UITabBarController* mVC = self.masterTabBarController;
	if (![mVC isKindOfClass:[UITabBarController class]])
		return nil;
	int selectedIndex = [mVC selectedIndex];
	if (selectedIndex < 0 || selectedIndex > [mVC viewControllers].count)
		selectedIndex = 0;
	id navController = mVC.selectedViewController;
	if ([navController isKindOfClass:[UINavigationController class]])
		return navController;

	return nil;
}

@end
