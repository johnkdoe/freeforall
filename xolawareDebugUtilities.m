//
//  xolawareDebugUtilities.h
//  xolaware utilities
//
//  Created by me on 2012.05.03.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareDebugUtilities.h"

@implementation xolawareDebugUtilities

+ (void)subViewsScrollToTopForView:(UIView*)uiView level:(int)level
{
	
	NSMutableString* str = [NSMutableString string];
	
	for (int i = 0; i < level; i++)
		[str appendString:@"  "];

	[str appendFormat:@"%@", [uiView class]];
	
	if ([uiView isKindOfClass:[UITableView class]]
		&& ![@"UITableView" isEqualToString:[str substringFromIndex:level*2]])
		[str appendString:@" : UITableView "];
	
	if ([uiView isKindOfClass:[UIScrollView class]]) {
		[str appendString:@" : UIScrollView "];
		
		UIScrollView* scrollView = (UIScrollView*)uiView;
		if (scrollView.scrollsToTop) {
			[str appendString:@" >>>scrollsToTop<<<<"];
		}
		NSLog(@"%@", str);
	} else if (uiView.subviews.count) {
		NSLog(@"%@", str);		
	}
	
	for (UIView* sv in uiView.subviews)
		[self subViewsScrollToTopForView:sv level:level+1];
}

@end
