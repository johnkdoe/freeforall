//
//  UINavigationController+NestedNavigationController.h
//  voyeur
//
//  Created by me on 2012.06.30.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@protocol NestedNavigationControllerHandler;

@interface UINavigationController (NestedNavigationController)

/**
 *
 * just hands off control to the handler implementing NestedNavigationControllerHandler.
 *
 * i.e. there is no fallback here.
 *
 * if the app nesting a navigation controller wants to fallback on popping only one
 * viewController, it should implement that.
 *
 * if it wants to always pop to the rootViewController, it should do that.
 * 
 * if the caller wants finer grain control, it should do that.
 */

- (UIViewController*)popToEligibleViewController:(id<NestedNavigationControllerHandler>)handler
										animated:(BOOL)animated;

@end
