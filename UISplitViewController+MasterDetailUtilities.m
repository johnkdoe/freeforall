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

- (UIViewController*)detailUIViewController {
	return [self topViewController:[self.viewControllers lastObject]];
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
	UINavigationController* navController = [[mVC viewControllers] objectAtIndex:selectedIndex];
	if ([navController isKindOfClass:[UINavigationController class]])
		return navController;
	
	return nil;
}

@end
