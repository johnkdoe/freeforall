//
//  xolawareComboPickerViewController.h
//  xolawareUI
//
//  Created by kb on 2012.12.10.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface xolawareComboPickerViewController : UIViewController
	<UIPickerViewDataSource, UIPickerViewDelegate>

// in storyboard, hook up a wrapper around the container for the picker so swipe-in can work
@property (readonly, nonatomic) IBOutlet UIView* contentView;

//	call this function in picker:didSelectRow:inComponent: to know whether to
//  make the picker disappear and post-process the selection into the corresponding button
- (BOOL)isStillSelecting;

// the names should explain what these do.
- (void)pickerFadeAway;
- (void)pickerFadeIn;
- (void)pickerSwipeInWithSelectedRow:(NSInteger)selectedRow viewForCenter:(UIView*)view;

@end
