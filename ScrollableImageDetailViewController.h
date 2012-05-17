//
//  ScrollableImageDetailViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface ScrollableImageDetailViewController
  : UIViewController<UIScrollViewDelegate, UISplitViewControllerDelegate>;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSURL* originatingURL;

- (void)resetSplitViewBarButtonTitle;
- (void)setImageTitle:(NSString*)imageTitle;

@end
