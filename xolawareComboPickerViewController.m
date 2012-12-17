//
//  xolawareComboPickerViewController.m
//  xolawareUI
//
//  Created by kb on 2012.12.10.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareComboPickerViewController.h"

@interface xolawareComboPickerViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView* comboPicker;
@property (weak, nonatomic) IBOutlet UIView* comboPickerContainer;
@end

@implementation xolawareComboPickerViewController
{
	// "pseudo combo-button" - CGFloat pseudoPickerTouchY
	//
	// this bit is the glue that ties a bunch of this together
	// - it will get set under all circumstances in UIGestureRecognizerDelegate optional member
	//   gestureRecognizer:shouldReceiveTouch:
	// - it will also get set when the picker view is visible in touchesBegan:withEvent:
	// - it should then get referenced in picker:didSelectRow:inComponent: to know whether to
	//   make the picker disappear and post-process the selection into the corresponding button
	//
	CGFloat _pseudoPickerTouchY;
}

#pragma mark - UIResponder override

// "pseudo combo-button" - touches outside the picker
//
// if the picker isn't dismissed when the app user touches outside of it, confusion will reign
// but if dismissed without gathering its contents, the app user will probably get frustrated
// for consistency, when the app user clicks outside the picker, whatever is currently selected
// at that time will get processed … unless it's other, in which case, we just fade away.
// the trick is to set the _pseudoPicker to a non-nil value that's in the milddle, approximating
// the current selection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!_comboPickerContainer.isHidden)
	{
		[self pickerFadeAway];
		return;	// default: even if another row is chosen, tapping outside means use original
	}

	[super touchesBegan:touches withEvent:event];
}

#pragma mark - public method implementation

- (BOOL)isStillSelecting {
	return 0 == _pseudoPickerTouchY;
}

- (void)pickerFadeAway {
	_pseudoPickerTouchY = 0;
	_comboPickerContainer.userInteractionEnabled = NO;
	[UIView animateWithDuration:0.22
					 animations:^{ _comboPickerContainer.alpha = 0; }
					 completion:^(BOOL finished) {
						 _comboPickerContainer.hidden = YES;
						 _comboPickerContainer.alpha = 1;
					 }];
}

- (void)pickerFadeIn {
	_comboPickerContainer.hidden = NO;
	_comboPickerContainer.userInteractionEnabled = YES;
	[UIView animateWithDuration:0.1666666 animations:^{ _comboPickerContainer.alpha = 1; }];
}

- (void)pickerSwipeInWithSelectedRow:(NSInteger)selectedRow viewForCenter:(UIView*)viewForCenter
{
	[_comboPickerContainer setCenter:viewForCenter.center];
	[_comboPicker reloadComponent:0];
	[_comboPicker selectRow:selectedRow inComponent:0 animated:NO];
	[_comboPicker setHidden:NO];
	CGRect pickerHome = _comboPickerContainer.frame;
	_comboPickerContainer.frame = CGRectMake(0-pickerHome.size.width, pickerHome.origin.y,
											 pickerHome.size.width, pickerHome.size.height);
	_comboPickerContainer.alpha = 1;
	_comboPickerContainer.hidden = NO;
	_comboPickerContainer.userInteractionEnabled = YES;
	[UIView animateWithDuration:0.22 animations:^{ _comboPickerContainer.frame = pickerHome; }];
}

#pragma mark - IBAction method implementations

// "pseudo combo-button" - (IBAction)tapInPickerGesture
//
// because tapping on the picker on a pre-selected item does not cause
// picker:didSelectRow:forComponent: to fire, we need another way to recognize that the user
// has tapped the selected row.  combined with the UIGestureRecognizerDelegate optional member
// implementation for gestureRecognizer:shouldReceiveTouch: below, this action is received only
// when the user taps in the appropriate part of the picker.  it then "fires" the
// pickerView:didSelectRow:inComponent; activity to complete the pseudo-selection behavior

- (IBAction)tapInPickerGesture:(UITapGestureRecognizer *)gesture {
	if (UIGestureRecognizerStateRecognized == gesture.state)
	{
		if ((.4 < _pseudoPickerTouchY) && (_pseudoPickerTouchY < .6))
		{
			NSInteger selectedRow = [_comboPicker selectedRowInComponent:0];
			[self pickerView:_comboPicker didSelectRow:selectedRow inComponent:0];
		}
	}
}


#pragma mark - UIGestureRecognizerDelegate protocol implementation
#pragma mark @optional ?

// "pseudo combo-button" - UIGestureRecognizerDelegate impl

// this bit has to do with giving up control of our pseudoPickerTouchY value when it is
// determined that the picker's internal UIScrollViewPanGestureRecognizer is at work and its
// state is not failed

- (BOOL)						  gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
 shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
	if (self == gestureRecognizer.delegate
		&& UIGestureRecognizerStateFailed != otherGestureRecognizer.state
		&& [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
	{
		_pseudoPickerTouchY = 0;
		return NO;
	}
	return YES;
}

// here is where the differentiation is made between the user clicking on a portion of the
// the picker that represents the current selection, and thus doesn't do anything, and the
// rest of the picker, which will actually cause the touched row to migrate to the part of the
// UI indicating it has been selected, and will then properly fire the activity
// picker:didSelectRow:forComponent: .  _pseudoPickerTouchY is set here, and will cover both
// cases of the UIPickerView picking a non-centered row and the UITapGestureRecognizer picking
// the main row.

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	   shouldReceiveTouch:(UITouch *)touch
{
	CGFloat viewTouchY = [touch locationInView:_comboPickerContainer].y;
	_pseudoPickerTouchY = viewTouchY / _comboPickerContainer.frame.size.height;
	return YES;
}

#pragma mark - UIPickerViewDataSource protocol implementation
#pragma mark @required

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
	assert(0);	// no default: should be implemented by subclass
}

@end
