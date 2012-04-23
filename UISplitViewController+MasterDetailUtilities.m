//
//  UISplitViewController+MasterDetailUtilities.m
//  theGRID
//
//  Created by me on 2012.04.22.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

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

@end
