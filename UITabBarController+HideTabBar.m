//
//  UITabBarController+HideTabBar.m
//  NPS
//
//  Created by Carlos Oliva on 04-02-12.

//	used by permission

#import "UITabBarController+HideTabBar.h"

#define kAnimationDuration .2


@implementation UITabBarController (HideTabBar)

// the self.view.frame.size.height can't be used directly in isTabBarHidden or
// in setTabBarHidden:animated: because the value may be the rect with a transform.
//
// further, an attempt to use CGSizeApplyAffineTransform() doesn't work because the
// value can produce a negative height.
// cf. http://lists.apple.com/archives/quartz-dev/2007/Aug/msg00047.html
//
// the crux is that CGRects are normalized, CGSizes are not.

- (BOOL)isTabBarHidden {
	CGRect viewFrame = CGRectApplyAffineTransform(self.view.frame, self.view.transform);
	CGRect tabBarFrame = self.tabBar.frame;
	return tabBarFrame.origin.y >= viewFrame.size.height;
}


- (void)setTabBarHidden:(BOOL)hidden {
	[self setTabBarHidden:hidden animated:NO];
}


- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
	BOOL isHidden = self.tabBarHidden;
	if (hidden == isHidden)
		return;
	UIView* transitionView = [self.view.subviews objectAtIndex:0];

	if (!transitionView)
	{
#if DEBUG
		NSLog(@"could not get the container view!");
#endif
		return;
	}

	CGRect viewFrame = CGRectApplyAffineTransform(self.view.frame, self.view.transform);
	CGRect tabBarFrame = self.tabBar.frame;
	CGRect containerFrame = transitionView.frame;
	tabBarFrame.origin.y = viewFrame.size.height - (hidden ? 0 : tabBarFrame.size.height);
	containerFrame.size.height = viewFrame.size.height - (hidden ? 0 : tabBarFrame.size.height);
	[UIView animateWithDuration:animated ? kAnimationDuration : 0
					 animations:^{
						 self.tabBar.frame = tabBarFrame;
						 transitionView.frame = containerFrame;
					 }
	 ];
}


@end