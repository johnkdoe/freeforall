//
//  UpsideDownRotation_6_0.m
//  athlete
//
//  Created by kb on 2012.10.30.
//  Copyright (c) 2012 kb. All rights reserved.
//

#import "UpsideDownRotation_6_0.h"

@implementation UINavigationController(UpsideDownRotation_6_0)
- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
@end

@implementation UISplitViewController(UpsideDownRotation_6_0)
- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
@end

@implementation UITabBarController(UpsideDownRotation_6_0)
- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
@end
