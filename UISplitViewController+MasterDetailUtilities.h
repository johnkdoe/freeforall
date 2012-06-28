//
//  UISplitViewController+MasterDetailUtilities.h
//  xolawareUI
//
//  Created by me on 2012.04.22.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface UISplitViewController (MasterDetailUtilities)
- (UIViewController*)masterUIViewController;
- (UIViewController<UISplitViewControllerDelegate>*)detailUIViewController;
- (UINavigationController*)selectedTabBarNavigationController;
@end
