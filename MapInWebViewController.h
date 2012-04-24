//
//  MapInWebViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.08.

#include "xolawareOpenSourceCopyright.h"	// Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface MapInWebViewController : UIViewController

@property (strong, nonatomic, readonly) IBOutlet UIWebView* webView;

@property (strong, nonatomic) NSString* locationInMap;

@end
