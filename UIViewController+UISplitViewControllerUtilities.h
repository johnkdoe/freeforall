//
//  UIViewController+UISplitViewControllerUtilities.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface UIViewController (UISplitViewControllerUtilities)
- (UIViewController*)masterViewController;
- (UIViewController*)detailViewController;
@end
