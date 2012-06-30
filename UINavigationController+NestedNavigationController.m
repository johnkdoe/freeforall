//
//  UINavigationController+NestedNavigationController.m
//  voyeur
//
//  Created by me on 2012.06.30.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "UINavigationController+NestedNavigationController.h"
#import "NestedNavigationControllerHandler.h"

@implementation UINavigationController (NestedNavigationController)

- (UIViewController*)popToEligibleViewController:(id<NestedNavigationControllerHandler>)handler
										animated:(BOOL)animated
{
	return [handler popToEligibleViewControllerUsing:self animated:animated];
}

@end
