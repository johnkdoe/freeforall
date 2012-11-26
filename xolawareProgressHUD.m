//
//  xolawareProgressHUD.m
//  athlete
//
//  Created by me on 2012.11.26.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareProgressHUD.h"

@implementation xolawareProgressHUD

- (void)showNowAndHideAfterDuration:(NSTimeInterval)duration {
	[self show:YES];
	[self hide:YES afterDelay:duration];
}

- (void)showText:(NSString*)labelText
	  andSubText:(NSString*)subText
		  inView:(UIView*)superView
		duration:(NSTimeInterval)duration
{
	self.animationType = MBProgressHUDAnimationZoomOut;
	self.mode = MBProgressHUDModeText;
	self.labelText = NSLocalizedString(labelText, nil);
	self.detailsLabelText = NSLocalizedString(subText, nil);

	if ([NSThread isMainThread])
	{
		[superView addSubview:self];
		[self showNowAndHideAfterDuration:duration];
	}
	else
		dispatch_async(dispatch_get_main_queue(), ^{
			[superView addSubview:self];
			[self showNowAndHideAfterDuration:duration];
		});
}
@end
