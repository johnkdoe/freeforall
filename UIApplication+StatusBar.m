//
//  UIApplication+StatusBar.m
//  denterpreter
//
//  Created by me on 2012.07.02.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "UIApplication+StatusBar.h"

@implementation UIApplication (StatusBar)

+ (CGRect)statusBarFrameForView:(UIView*)v {
    return [v convertRect:[v.window convertRect:[self sharedApplication].statusBarFrame fromWindow:nil] fromView:nil];
}

@end
