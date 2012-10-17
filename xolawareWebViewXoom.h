//
//  xolawareWebViewXoom.h
//  xolawareUI
//
//  Created by kb on 2012.10.12.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface xolawareWebViewXoom : NSObject <UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, getter = hasAnchor) BOOL anchor;

- (id)initWithWebView:(UIWebView*)webView;

- (void)didRotate;
- (void)willRotate;

@end
