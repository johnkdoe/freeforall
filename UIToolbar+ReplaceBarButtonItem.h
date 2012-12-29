//
//  UIToolbar+ReplaceBarButtonItem.h
//  athlete
//
//  Created by kb on 2012.12.22.
//  Copyright (c) 2012 kb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (ChangeItems)

- (void)replaceItemAtIndex:(NSUInteger)index withBarButtonItem:(UIBarButtonItem*)barButtonItem;
- (void)removeItemAtIndex:(NSUInteger)index;

@end
