//
//  NestedNavigationControllerHandler.h
//  voyeur
//
//  Created by me on 2012.06.30.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@protocol NestedNavigationControllerHandler <NSObject>

- (UIViewController*)popToEligibleViewControllerUsing:(UINavigationController*)uiNavController
											 animated:(BOOL)animated;

@end
