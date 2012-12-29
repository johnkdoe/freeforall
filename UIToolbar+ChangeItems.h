//
//  UIToolbar+ChangeItems.h
//  xolawareUI
//
//  Created by kb on 2012.12.22.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface UIToolbar (ChangeItems)

- (void)replaceItemAtIndex:(NSUInteger)index withBarButtonItem:(UIBarButtonItem*)barButtonItem;
- (void)removeItemAtIndex:(NSUInteger)index;

@end
