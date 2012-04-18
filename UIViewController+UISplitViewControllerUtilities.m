//
//  UIViewController+UISplitViewControllerUtilities.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "UIViewController+UISplitViewControllerUtilities.h"

@implementation UIViewController (UISplitViewControllerUtilities)

- (UIViewController*)masterViewController
{
	return [self.splitViewController.viewControllers objectAtIndex:0];
}

- (UIViewController*)detailViewController
{
	return [[self.splitViewController.viewControllers lastObject] topViewController];
}

@end
