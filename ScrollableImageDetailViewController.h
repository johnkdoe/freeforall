//
//  ScrollableImageDetailViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "KludgeWorkaroundForBuggySplitViewDelegateStartup.h"
#import "NestedNavigationControllerHandler.h"
#import "SplitViewTitle.h"

@interface ScrollableImageDetailViewController : UIViewController
	<UIScrollViewDelegate, SplitViewTitle>;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSURL* originatingURL;

@property (weak, nonatomic) id<NestedNavigationControllerHandler> nestedNavControllerHandler;

- (void)setImageTitle:(NSString*)imageTitle;

@end
