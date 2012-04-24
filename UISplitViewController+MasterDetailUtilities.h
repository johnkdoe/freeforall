//
//  UISplitViewController+MasterDetailUtilities.h
//  theGRID
//
//  Created by me on 2012.04.22.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISplitViewController (MasterDetailUtilities)
- (UIViewController*)masterUIViewController;
- (UIViewController*)detailUIViewController;
- (UITabBarController*)masterTabBarController;
@end
