//
//  ScrollableImageDetailViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollableImageDetailViewController
  : UIViewController<UIScrollViewDelegate, UISplitViewControllerDelegate>;

@property (strong, nonatomic) UIImage* image;

- (void)resetSplitViewBarButtonTitle;
- (void)setImageTitle:(NSString*)imageTitle;

@end
