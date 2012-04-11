//
//  UIViewController+UISplitViewControllerUtilities.h
//  XolawareUI
//
//  Created by me on 2012.04.07.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UISplitViewControllerUtilities)
- (UIViewController*)masterViewController;
- (UIViewController*)detailViewController;
@end
