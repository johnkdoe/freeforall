//
//  UIToolbar+ReplaceBarButtonItem.m
//  athlete
//
//  Created by kb on 2012.12.22.
//  Copyright (c) 2012 kb. All rights reserved.
//

#import "UIToolbar+ReplaceBarButtonItem.h"

@implementation UIToolbar (ReplaceBarButtonItem)

- (void)replaceItemAtIndex:(NSUInteger)index withBarButtonItem:(UIBarButtonItem*)barButtonItem
{
	NSMutableArray* replacementToolbarItems = self.items.mutableCopy;
	[replacementToolbarItems replaceObjectAtIndex:index withObject:barButtonItem];
	self.items = replacementToolbarItems.copy;
}

@end
