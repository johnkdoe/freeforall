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
	if ([controller isKindOfClass:[UITabBarController class]])
		controller = [controller selectedViewController];
	if ([controller respondsToSelector:@selector(topViewController)])
		return [controller topViewController];
	return nil;
}

- (UITabBarController*)masterTabBarController {
	id controller = [self.viewControllers objectAtIndex:0];
	if ([controller isKindOfClass:[UITabBarController class]])
		return controller;
	return nil;
}

- (NSString*)masterTitle {
	return [(UIViewController*)[self.viewControllers objectAtIndex:0] title];
}

- (UIViewController*)masterUIViewController {
	return [self topViewController:[self.viewControllers objectAtIndex:0]];
}

- (UIViewController*)detailUIViewController {
	id controller = [self topViewController:[self.viewControllers lastObject]]; 
	assert([controller isKindOfClass:[UIViewController class]]);
	return (UIViewController*)controller;
}

@end
