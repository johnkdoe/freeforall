//
//  ScrollableImageDetailViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "KludgeWorkaroundForBuggySplitViewDelegateStartup.h"

@interface ScrollableImageDetailViewController
  : KludgeWorkaroundForBuggySplitViewDelegateStartup<UIScrollViewDelegate>;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSURL* originatingURL;

- (void)resetSplitViewBarButtonTitle;
- (void)setImageTitle:(NSString*)imageTitle;

@end
