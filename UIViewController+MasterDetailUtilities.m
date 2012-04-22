//
//  UIViewController+MasterDetailUtilities.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "UIViewController+MasterDetailUtilities.h"

@implementation UIViewController (MasterDetailUtilities)

- (UIViewController*)masterViewController
{
	if (self.splitViewController)	// i.e. iPad
		return [self.splitViewController.viewControllers objectAtIndex:0];
	else
		return self.navigationController.topViewController;
}

- (UIViewController*)detailViewController
{
	// if splitViewController is nil, then this is iPhone, and nil will be returned
	return [[self.splitViewController.viewControllers lastObject] topViewController];
}

@end
