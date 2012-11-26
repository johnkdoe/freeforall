//
//  xolawareProgressHUD.h
//  athlete
//
//  Created by me on 2012.11.26.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "MBProgressHUD.h"

@interface xolawareProgressHUD : MBProgressHUD

- (void)showText:(NSString*)labelText
	  andSubText:(NSString*)subText
		  inView:(UIView*)superView
		duration:(NSTimeInterval)duration;

@end
