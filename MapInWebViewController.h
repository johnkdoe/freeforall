//
//  MapInWebViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.08.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapInWebViewController : UIViewController

@property (strong, nonatomic, readonly) IBOutlet UIWebView* webView;

@property (strong, nonatomic) NSString* locationInMap;

@end
