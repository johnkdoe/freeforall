//
//  UITabBarController+HideTabBar.m
//  NPS
//
//  Created by Carlos Oliva on 04-02-12.

//	used by permission

#import "UITabBarController+HideTabBar.h"

#define kAnimationDuration .2


@implementation UITabBarController (HideTabBar)

- (BOOL)isTabBarHidden {
	CGRect viewFrame = self.view.frame;
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
	UIView* transitionView
	  = [[[self.view.subviews reverseObjectEnumerator] allObjects] lastObject];

	if (!transitionView)
	{
		NSLog(@"could not get the container view!");
		return;
	}

	CGFloat viewFrameHeight = self.view.frame.size.height;
	CGRect tabBarFrame = self.tabBar.frame;
	CGRect containerFrame = transitionView.frame;
	tabBarFrame.origin.y = viewFrameHeight - (hidden ? 0 : tabBarFrame.size.height);
	containerFrame.size.height = viewFrameHeight - (hidden ? 0 : tabBarFrame.size.height);
	[UIView animateWithDuration:kAnimationDuration 
					 animations:^{
						 self.tabBar.frame = tabBarFrame;
						 transitionView.frame = containerFrame;
					 }
	 ];
}


@end