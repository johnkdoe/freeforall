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

/**
 *	the ViewController using this companion is expected to invoke these functions in the
 *	appropriate will/did life cycle rotation functions.
 */

- (void)didRotate;
- (void)willRotate;


/**
 *	the ViewController using this companion is expected to invoke this whenever removing
 *	or rotating a URL containing an anchor.
 */

- (void)removeOrRotateAnchorBaseURL:(NSURL *)urlWithoutAnchor;

@end
