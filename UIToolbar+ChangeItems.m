//
//  UIToolbar+ChangeItems.m
//  xolawareUI
//
//  Created by kb on 2012.12.22.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "UIToolbar+ChangeItems.h"

@implementation UIToolbar (ChangeItems)

- (void)replaceItemAtIndex:(NSUInteger)index withBarButtonItem:(UIBarButtonItem*)barButtonItem
{
	NSMutableArray* replacementToolbarItems = self.items.mutableCopy;
	[replacementToolbarItems replaceObjectAtIndex:index withObject:barButtonItem];
	self.items = replacementToolbarItems.copy;
}

- (void)removeItemAtIndex:(NSUInteger)index
{
	NSMutableArray* replacementToolbarItems = self.items.mutableCopy;
	[replacementToolbarItems removeObjectAtIndex:index];
	self.items = replacementToolbarItems.copy;
}

@end
