//
//  FlipsideViewController.h
//  xolawareUI
//
//  Created by me on 2012.04.14.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate <NSObject>
- (void)flipsideViewControllerDidFinish:(FlipsideViewController*)controller;
@optional
@property (nonatomic) BOOL scrollsToTop;
- (void)flipsideViewControllerWillPop:(FlipsideViewController*)controller;
@end

@interface FlipsideViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#error deployment target must be a minimum of iOS 4.0 to use this class
#elif __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
@property (weak, nonatomic) NSURL* originatingURL;
@property (weak, nonatomic) id<FlipsideViewControllerDelegate> flipsideViewControllerDelegate;
#else
@property (unsafe_unretained, nonatomic) NSURL* originatingURL;
@property (unsafe_unretained, nonatomic) id<FlipsideViewControllerDelegate> flipsideViewControllerDelegate;
#endif

@end
