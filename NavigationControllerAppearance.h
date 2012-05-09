//
//  NavigationControllerAppearance.h
//  xolaware
//
//  Created by me on 2012.05.09.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavigationControllerAppearance
@optional

- (void)navigationController:(UINavigationController*)navigationController
setTitleTextAttributesForOrientation:(UIInterfaceOrientation)orientation;

@end
